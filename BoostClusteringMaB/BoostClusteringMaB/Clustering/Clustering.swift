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

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        queue.underlyingQueue = .global()
        return queue
    }()

    init(coreDataLayer: CoreDataManager) {
        self.coreDataLayer = coreDataLayer
    }

    func findOptimalClustering(southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
        queue.isSuspended = true
        queue.cancelAllOperations()
        let poi = coreDataLayer.fetch(southWest: southWest, northEast: northEast, sorted: true)
        guard let pois = poi?.map({$0.toPOI()}) else { return }
        guard !pois.isEmpty else { return }
        runKMeans(pois: pois, zoomLevel: zoomLevel)
    }

    private func runKMeans(pois: [POI], zoomLevel: Double) {
        let integer = Int(zoomLevel)
        let startRange = (integer - 10 <= 0) ? 2 : integer - 10
        let kRange = (startRange...integer)

        let kMeansArr = kRange.map { k in
            KMeans(k: k, pois: pois)
        }

        queue.addOperations(kMeansArr, waitUntilFinished: false)

        queue.addBarrierBlock { [weak self] in
            let kMeansTuple = kMeansArr.map { (kMeans: $0, DBI: $0.daviesBouldinIndex()) }
            guard let minKMeans = kMeansTuple.min(by: { lhs, rhs in lhs.DBI < rhs.DBI })?.kMeans else { return }
            DispatchQueue.main.async {
                self?.groupNotifyTasks(minKMeans)
            }
        }

        queue.isSuspended = false
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
        let stdDistance: Double = 60
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
