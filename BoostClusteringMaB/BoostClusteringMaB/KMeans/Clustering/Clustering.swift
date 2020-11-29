//
//  Clustering.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//

import NMapsMap

class Clustering {
    typealias LatLngs = [LatLng]

    private let naverMapView: NMFMapViewProtocol
    private let coreDataLayer: CoreDataManager

    init(naverMapView: NMFMapViewProtocol, coreDataLayer: CoreDataManager) {
        self.naverMapView = naverMapView
        self.coreDataLayer = coreDataLayer
    }

    func refreshPoints() -> [LatLng] {
        let boundsLatLngs = naverMapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])

        guard let fetchPoints = try? coreDataLayer.fetch(southWest: southWest,
                                                         northEast: northEast,
                                                         sorted: true) else { return [] }

        return fetchPoints.map({poi in LatLng(lat: poi.latitude, lng: poi.longitude)})
    }

    func findOptimalClustering(completion: @escaping (LatLngs, [Int], [LatLngs]) -> Void) {
        let kRange = (2...10)
        let points = refreshPoints()
        var minValue = Double.greatestFiniteMagnitude
        var minKMeans: KMeans?
        
        let group = DispatchGroup.init()
        let serialQueue = DispatchQueue.init(label: "serial")
        
        kRange.forEach { k in
            DispatchQueue.global(qos: .userInteractive).async(group: group) {
                let kMeans = KMeans(k: k, points: points)
                kMeans.run()
                
                let DBI = kMeans.daviesBouldinIndex()
                serialQueue.async(group: group) {
                    if DBI <= minValue {
                        minValue = DBI
                        minKMeans = kMeans
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let minKMeans = minKMeans,
                  let combinedClusters = self?.combineClusters(clusters: minKMeans.clusters)
            else { return }

            var points = [Int]()
            var centroids = LatLngs()
            var convexHullPoints = [LatLngs]()

            combinedClusters.forEach({
                points.append($0.points.size)
                centroids.append($0.center)
                convexHullPoints.append($0.area())
            })

            completion(centroids, points, convexHullPoints)
        }
    }
    
    func combineClusters(clusters: [Cluster]) -> [Cluster] {
        let stdDistance: Double = 90
        var newClusters = clusters
        
        for i in 0..<clusters.count {
            for j in 0..<clusters.count where i < j {
                let point1 = convertLatLngToPoint(latLng: clusters[i].center)
                let point2 = convertLatLngToPoint(latLng: clusters[j].center)
                let distance = point1.distance(to: point2)
                
                //                let distance = cenvertLatLngToPoint(latLng1: clusters[i].center, latLng2: clusters[j].center)
                
                if stdDistance > distance {
                    newClusters[i].combine(other: newClusters[j])
                    newClusters.remove(at: j)
                    return combineClusters(clusters: newClusters)
                }
            }
        }
        return clusters
    }
    
    func convertLatLngToPoint(latLng1: LatLng, latLng2: LatLng) -> Double {
        let mercatorCoord = NMGWebMercatorCoord(from: NMGLatLng(lat: latLng1.lat, lng: latLng1.lng))
        let mercatorCoord2 = NMGWebMercatorCoord(from: NMGLatLng(lat: latLng2.lat, lng: latLng2.lng))
        let metersPerPixel = naverMapView.projection.metersPerPixel()
        
        return (mercatorCoord.distance(to: mercatorCoord2) / metersPerPixel)
    }
    
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        let projection = naverMapView.projection
        let point = projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
        return point
    }
}
