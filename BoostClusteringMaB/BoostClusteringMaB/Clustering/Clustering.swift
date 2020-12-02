//
//  Clustering.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//
import Foundation

class Clustering {
    typealias LatLngs = [LatLng]

    weak var data: ClusteringData?
    weak var tool: ClusteringTool?
    
    private let coreDataLayer: CoreDataManager

    init(coreDataLayer: CoreDataManager) {
        self.coreDataLayer = coreDataLayer
    }
    
    let group = DispatchGroup.init()

    func findOptimalClustering(southWest: LatLng, northEast: LatLng) {
        let poi = coreDataLayer.fetch(southWest: southWest, northEast: northEast, sorted: true)
        guard let pois = poi?.map({$0.toPOI()}) else { return }
        guard !pois.isEmpty else {
            return
        }
        runKMeans(pois: pois)
    }

    private func runKMeans(pois: [POI]) {
        let kRange = (2...10)
        var minValue = Double.greatestFiniteMagnitude
        var minKMeans: KMeans?
        let serialQueue = DispatchQueue.init(label: "serial")

        kRange.forEach { k in
            DispatchQueue.global(qos: .userInteractive).async(group: group) {
                let kMeans = KMeans(k: k, pois: pois)
                kMeans.run()

                let DBI = kMeans.daviesBouldinIndex()
                serialQueue.async(group: self.group) {
                    if DBI <= minValue {
                        minValue = DBI
                        minKMeans = kMeans
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let minKMeans = minKMeans else { return }
            self?.groupNotifyTasks(minKMeans)
        }
    }

    private func groupNotifyTasks(_ minKMeans: KMeans) {
        let combinedClusters = self.combineClusters(clusters: minKMeans.clusters)

        var points = [Int]()
        var centroids = LatLngs()
        var convexHullPoints = [LatLngs]()
        var bounds = [(southWest: LatLng, northEast: LatLng)]()

        combinedClusters.forEach({ cluster in
            points.append(cluster.pois.size)
            centroids.append(cluster.center)
            convexHullPoints.append(cluster.area())
            bounds.append((southWest: cluster.southWest(),
                           northEast: cluster.northEast()))
        })
        
        self.data?.redrawMap(centroids, points, bounds, convexHullPoints)
    }
    
    func combineClusters(clusters: [Cluster]) -> [Cluster] {
        let stdDistance: Double = 90
        var newClusters = clusters
        
        for i in 0..<clusters.count {
            for j in 0..<clusters.count where i < j {
                guard let point1 = tool?.convertLatLngToPoint(latLng: clusters[i].center),
                      let point2 = tool?.convertLatLngToPoint(latLng: clusters[j].center) else { return [] }
                let distance = point1.distance(to: point2)
                
                if stdDistance > distance {
                    newClusters[i].combine(other: newClusters[j])
                    newClusters.remove(at: j)
                    return combineClusters(clusters: newClusters)
                }
            }
        }
        return clusters
    }
}
