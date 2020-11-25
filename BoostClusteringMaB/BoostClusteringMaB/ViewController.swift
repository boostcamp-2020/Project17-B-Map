//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    lazy var naverMapView = NMFMapView(frame: view.frame)
    let markerImageView = MarkerImageView(radius: 30)
    var markers = [NMFMarker]()
    var poiData: [POI]?

    let coreDataLayer: CoreDataManager = CoreDataLayer()

    let animationOperationQueue = OperationQueue.main

    override func viewDidLoad() {
        super.viewDidLoad()
        //        jsonToData(name: "gangnam_8000")

        configureMapView()
    }
    
    private func configureMapView() {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587)) // 강남
        // let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.56295485320913, lng: 126.99235958053829)) // 을지로
        
        view.addSubview(naverMapView)
        naverMapView.touchDelegate = self
        naverMapView.addCameraDelegate(delegate: self)
        naverMapView.moveCamera(cameraUpdate)
    }
    
    func addMarker(latLng: LatLng) -> NMFMarker {
        let marker = NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
        return marker
    }
    
    private func jsonToData(name: String) {
        if let path = Bundle.main.url(forResource: name, withExtension: "json") {
            guard let data = try? Data(contentsOf: path) else { return  }
            let jsonResult = try? JSONDecoder().decode(Places.self, from: data)
            jsonResult?.places.forEach({
                try? coreDataLayer.add(place: $0) {
                    try? self.coreDataLayer.save()
                }
            })
        }
    }
    
    //    func generatePoints() -> [LatLng] {
    //        guard let xList = poiData?.places.compactMap({Double($0.x)}) else { return [] }
    //        guard let yList = poiData?.places.compactMap({Double($0.y)}) else { return [] }
    //
    //        var points = [LatLng]()
    //        for (x, y) in zip(xList, yList) {
    //            points.append(LatLng(lat: y, lng: x))
    //        }
    //        return points
    //    }

    func findOptimalClustering(completion: @escaping ([LatLng], [Int]) -> Void) {
        let boundsLatLngs = naverMapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])

        guard let points = try? coreDataLayer.fetch(southWest: southWest,
                                                    northEast: northEast).map({poi in
                                                        LatLng(lat: poi.latitude, lng: poi.longitude)
                                                    }) else { return }

        guard !points.isEmpty else { return }

        let sortedPoints = points.sorted(by: <)

        let kRange = (2...8)

        var minValue = Double.greatestFiniteMagnitude
        var minKMeans: KMeans?

        let group = DispatchGroup.init()
        let serialQueue = DispatchQueue.init(label: "serial")

        kRange.forEach { k in
            DispatchQueue.global(qos: .userInteractive).async(group: group) {
                let kMeans = KMeans(k: k, points: sortedPoints)
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
            guard let minKMeans = minKMeans else { return }
            self?.combineClusters(kMeans: minKMeans, clusters: minKMeans.clusters)
            let points = minKMeans.clusters.map({$0.points.size})
            completion(minKMeans.centroids, points)

        }
    }
    
    func combineClusters(kMeans: KMeans, clusters: [Cluster]) {
        let stdDistance: Double = 50 //추후 클러스터 크기에 따라 변동가능성
        
        for i in 0..<clusters.count {
            for j in 0..<clusters.count {
                if i == j { continue }
                let point1 = convertLatLngToPoint(latLng: clusters[i].center)
                let point2 = convertLatLngToPoint(latLng: clusters[j].center)
                let distance = point1.distance(to: point2)
                if stdDistance > distance {
                    clusters[i].combine(other: clusters[j])
                    let newClusters = clusters.filter { $0 != clusters[j] }
                    kMeans.clusters = newClusters
                    combineClusters(kMeans: kMeans, clusters: newClusters)
                    return
                }
            }
        }
    }
    
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        let projection = naverMapView.projection
        let point = projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
        return point
    }
    var newMarkers: [NMFMarker]?
}

extension ViewController: NMFMapViewCameraDelegate {
    enum ClusteringAnimationType {
        case merge, divide
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        findOptimalClustering(completion: { [weak self] array, pointSize in
            guard let self = self else { return }

            let newMarkers: [NMFMarker] = zip(array, pointSize).map {
                let marker = self.addMarker(latLng: $0)
                if $1 != 1 {
                    marker.setImageView(self.markerImageView, count: $1)
                }
                return marker
            }

            guard self.markers.count != 0 else {
                newMarkers.forEach { $0.mapView = self.naverMapView }
                self.markers = newMarkers
                return
            }

            guard self.markers.count != newMarkers.count else { return }

            self.markers.forEach({
                $0.mapView = nil
            })

            self.markers = newMarkers

            self.markers.forEach({
                $0.mapView = self.naverMapView
            })
            //            if self.markers.count > newMarkers.count {
            //                self.markerClustringAnimation(.merge, newMarkers)
            //            } else if self.markers.count < newMarkers.count {
            //                self.markerClustringAnimation(.divide, newMarkers)
            //            }
        })
    }

    private func markerClustringAnimation(_ type: ClusteringAnimationType, _ newMarkers: [NMFMarker]) {
        let upperMarkers = (type == .merge) ? newMarkers : markers
        let lowerMarkers = (type == .merge) ? markers : newMarkers
        
        switch type {
        case .merge:
            newMarkers.forEach { $0.mapView = naverMapView }
        case .divide:
            markers.forEach { $0.mapView = nil }
        }
        
        lowerMarkers.forEach { lowerMarker in
            var nearestMarker = upperMarkers[0]
            var minDistance = squaredDistance(lowerMarker, nearestMarker)
            
            upperMarkers[1...].forEach { upperMarker in
                let newDistance = squaredDistance(lowerMarker, upperMarker)
                if newDistance < minDistance {
                    nearestMarker = upperMarker
                    minDistance = newDistance
                }
            }
            
            switch type {
            case .merge:
                let lat = nearestMarker.position.lat
                let lng = nearestMarker.position.lng
                lowerMarker.moveWithAnimation(naverMapView,
                                              to: .init(lat: lat, lng: lng),
                                              queue: animationOperationQueue) {
                    lowerMarker.mapView = nil
                }
                
            case .divide:
                let lat = lowerMarker.position.lat
                let lng = lowerMarker.position.lng
                lowerMarker.position = .init(lat: nearestMarker.position.lat,
                                             lng: nearestMarker.position.lng)
                lowerMarker.mapView = naverMapView
                lowerMarker.moveWithAnimation(naverMapView,
                                              to: .init(lat: lat, lng: lng),
                                              queue: animationOperationQueue,
                                              complete: nil)
            }
        }
        markers = newMarkers
    }
    
    private func squaredDistance(_ lhs: NMFMarker, _ rhs: NMFMarker) -> Double {
        return pow(lhs.position.lat - rhs.position.lat, 2) + pow(lhs.position.lng - rhs.position.lng, 2)
    }
}

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        let marker = NMFMarker(position: latlng)
        marker.mapView = mapView
        marker.setImageView(markerImageView, count: 0)
    }
}

extension NMFMarker {
    func setImageView(_ view: MarkerImageView, count: Int) {
        view.text = "\(count)"
        iconImage = .init(image: view.snapshot())
    }
}
