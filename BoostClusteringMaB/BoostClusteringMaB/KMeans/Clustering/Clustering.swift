//
//  Clustering.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//

import NMapsMap

protocol ClusteringData: class {
    func poiCoordinate(_ latLngs: [LatLng], _ pointSizes: [Int])
    func drawArea(_ bounds: [NMGLatLngBounds], _ convexHullPoints: [[LatLng]])
//    func convexHullPoints(_ data: [[LatLng]])
//    func bounds(_ data: [NMGLatLngBounds])
}

class Clustering {
    typealias LatLngs = [LatLng]

    weak var data: ClusteringData?

    private let naverMapView: NMFMapViewProtocol
    private let coreDataLayer: CoreDataManager

    init(naverMapView: NMFMapViewProtocol, coreDataLayer: CoreDataManager) {
        self.naverMapView = naverMapView
        self.coreDataLayer = coreDataLayer
    }

//    func refreshPoints() -> [LatLng] {
//        let boundsLatLngs = naverMapView.coveringBounds.boundsLatLngs
//        let southWest = LatLng(boundsLatLngs[0])
//        let northEast = LatLng(boundsLatLngs[1])
//
//        guard let fetchPoints = try? coreDataLayer.fetch(southWest: southWest,
//                                                         northEast: northEast,
//                                                         sorted: true) else { return [] }
//
//        return fetchPoints.map({poi in LatLng(lat: poi.latitude, lng: poi.longitude)})
//    }
    let group = DispatchGroup.init()

    func findOptimalClustering() {
        let boundsLatLngs = naverMapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])

        coreDataLayer.fetch(southWest: southWest, northEast: northEast, sorted: true) { result in
            guard let points = try? result.get().map({ poi in
                LatLng(lat: poi.latitude, lng: poi.longitude)
            }) else { return }

            guard !points.isEmpty else { return }

            runKMeans(points: points)
        }
    }

    func runKMeans(points: [LatLng]) {
        let kRange = (2...10)
        var minValue = Double.greatestFiniteMagnitude
        var minKMeans: KMeans?
        let serialQueue = DispatchQueue.init(label: "serial")

        kRange.forEach { k in
            DispatchQueue.global(qos: .userInteractive).async(group: group) {
                let kMeans = KMeans(k: k, points: points)
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

    func groupNotifyTasks(_ minKMeans: KMeans) {
        let combinedClusters = self.combineClusters(clusters: minKMeans.clusters)

        var points = [Int]()
        var centroids = LatLngs()
        var convexHullPoints = [LatLngs]()
        var bounds = [NMGLatLngBounds]()

        combinedClusters.forEach({ cluster in
            points.append(cluster.points.size)
            centroids.append(cluster.center)
            convexHullPoints.append(cluster.area())
            bounds.append(NMGLatLngBounds(southWest: cluster.southWest().convert(),
                                          northEast: cluster.northEast().convert()))
        })
        
        self.data?.poiCoordinate(centroids, points)
        self.data?.drawArea(bounds, convexHullPoints)
//        self.data?.convexHullPoints(convexHullPoints)
//        self.data?.bounds(bounds)
    }
    
    func combineClusters(clusters: [Cluster]) -> [Cluster] {
        let stdDistance: Double = 90
        var newClusters = clusters
        
        for i in 0..<clusters.count {
            for j in 0..<clusters.count where i < j {
                let point1 = convertLatLngToPoint(latLng: clusters[i].center)
                let point2 = convertLatLngToPoint(latLng: clusters[j].center)
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

    // MARK: - WebMercatorCoord
    func convertLatLngToPoint(latLng1: LatLng, latLng2: LatLng) -> Double {
        let mercatorCoord = NMGWebMercatorCoord(from: NMGLatLng(lat: latLng1.lat, lng: latLng1.lng))
        let mercatorCoord2 = NMGWebMercatorCoord(from: NMGLatLng(lat: latLng2.lat, lng: latLng2.lng))
        let metersPerPixel = naverMapView.projection.metersPerPixel()
        
        return (mercatorCoord.distance(to: mercatorCoord2) / metersPerPixel)
    }

    // MARK: - 화면좌표
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        let projection = naverMapView.projection
        let point = projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
        return point
    }
}
