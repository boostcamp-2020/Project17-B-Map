//
//  KMeans.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import Foundation

class KMeans: Operation {
    let k: Int
    let pois: [POI]
    var clusters: [Cluster]
    var isChanged: Bool
    var centroids: [LatLng] {
        return clusters.map { $0.center }
    }
    
    var dbi = Double.greatestFiniteMagnitude

    init(k: Int, pois: [POI]) {
        self.k = k
        self.pois = pois
        self.clusters = []
        self.isChanged = false
    }

    override var isAsynchronous: Bool {
        true
    }

    override func main() {
        guard !isCancelled else { return }
        run()
        daviesBouldinIndex()
    }

    func runOperation(_ operations: [() -> Void]) {
        guard !isCancelled else { return }
        self.queuePriority = QueuePriority(rawValue: k + 4) ?? .high
        operations.forEach({
            $0()
        })
    }

    func run() {
        let maxIteration = 5
        let initCenters = randomCentersByPointsIndex(count: k, pois: pois)
        clusters = generateClusters(centers: initCenters)
        runOperation([classifyPoints, updateCenters])

        var iteration = 0
        repeat {
            runOperation([updatePoints, updateCenters])
            iteration += 1
        } while isChanged && (iteration < maxIteration) && !isCancelled
    }
    
    private func randomCentersByPointsIndex(count: Int, pois: [POI]) -> [POI] {
        guard pois.count > count else { return pois }
        guard let firstPoint = pois.first else { return [] }
        
        var result = [firstPoint]
        switch count {
        case 1:
            return result
        default:
            let diff = pois.count / (count - 1)
            (1..<count).forEach {
                result.append(pois[$0 * diff - 1])
            }
            return result
        }
    }
    
    private func generateClusters(centers: [POI]) -> [Cluster] {
        let centroids = centers.map { LatLng(lat: $0.latLng.lat, lng: $0.latLng.lng) }
        return centroids.map { Cluster(center: $0) }
    }
    
    private func classifyPoints() {
        pois.forEach {
            let cluster = findNearestCluster(poi: $0)
            cluster.add(poi: $0)
        }
    }
    
    private func updateCenters() {
        clusters.forEach {
            $0.updateCenter()
        }
    }
    
    private func updatePoints() {
        isChanged = false
        
        clusters.forEach { cluster in
            let pois = cluster.pois
            pois.setNowToHead()
            for _ in 0..<pois.size {
                guard let poi = pois.now?.value else { pois.moveNowToNext(); break }
                let nearestCluster = findNearestCluster(poi: poi)
                if cluster == nearestCluster { pois.moveNowToNext(); continue }
                
                isChanged = true
                nearestCluster.add(poi: poi)
                cluster.remove(poi: poi)
                pois.moveNowToNext()
            }
        }
    }
    
    private func findNearestCluster(poi: POI) -> Cluster {
        var minDistance = Double.greatestFiniteMagnitude
        var nearestCluster = Cluster.greatestFinite
        let point = LatLng(lat: poi.latLng.lat, lng: poi.latLng.lng)
        
        clusters.forEach {
            let newDistance = $0.center.squaredDistance(to: point)
            if newDistance < minDistance {
                nearestCluster = $0
                minDistance = newDistance
            }
        }
        return nearestCluster
    }

    func daviesBouldinIndex() {
        var sum: Double = 0
        let deviations = clusters.map { $0.deviation() }
        
        for i in 0..<clusters.count {
            var maxValue: Double = 0
            for j in 0..<clusters.count where i != j {
                let sumOfDeviations = deviations[i] + deviations[j]
                let distanceCenters = clusters[i].center.distance(to: clusters[j].center)
                maxValue = max(maxValue, sumOfDeviations / distanceCenters)
            }
            sum += maxValue
        }
        
        let result = sum / Double(clusters.count)
        dbi = result
    }
}
