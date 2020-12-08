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

    private let dbiOperationQueue = OperationQueue()

    init(coreDataLayer: CoreDataManager) {
        self.coreDataLayer = coreDataLayer
        dbiOperationQueue.maxConcurrentOperationCount = 1
    }

    func findOptimalClustering(southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
//        queue.isSuspended = true
        queue.cancelAllOperations()
        let poi = coreDataLayer.fetch(southWest: southWest, northEast: northEast, sorted: true)
        guard let pois = poi?.map({$0.toPOI()}) else { return }
        guard !pois.isEmpty else { return }
        runKMeans(pois: pois, zoomLevel: zoomLevel)
    }

    private func runKMeans(pois: [POI], zoomLevel: Double) {
        let kRange = findKRange(zoomLevel: Int(zoomLevel))

        var minKmeans: KMeans = .init(k: 0, pois: [])
        var minDBI: Double = .greatestFiniteMagnitude

        kRange.forEach { k in
            let kMeans = KMeans(k: k, pois: pois)

            let operation = BlockOperation {
                let dbi = kMeans.daviesBouldinIndex()
                if minDBI > dbi {
                    minDBI = dbi
                    minKmeans = kMeans
                }
            }

            operation.addDependency(kMeans)
            queue.addOperations([kMeans, operation], waitUntilFinished: false)
        }

//        queue.addOperations(kMeansArr, waitUntilFinished: false)

        queue.addBarrierBlock { [weak self] in
            DispatchQueue.main.async {
                self?.groupNotifyTasks(minKmeans)
            }

        }

//        queue.isSuspended = false
    }

    func processTime(blockFunction: () -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        blockFunction()
        let processTime = CFAbsoluteTimeGetCurrent() - startTime
        print("걸린 시간 = \(processTime)")
    }

    private func findKRange(zoomLevel: Int) -> ClosedRange<Int> {
        let start: Int
        let end: Int
        
        let favorite = (14...17) // 사람들이 자주 쓰는 줌레벨
        if favorite.contains(zoomLevel) {
            start = zoomLevel - 10
        } else {
            start = 2
        }
        end = start + 10
        
        return (start...end)
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
            let cluster = cluster.southWestAndNorthEast()
            bounds.append((southWest: cluster.southWest,
                           northEast: cluster.northEast))
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
