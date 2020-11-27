//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    lazy var naverMapView = NMFNaverMapView(frame: view.frame)
    lazy var markerImageView = MarkerImageView(radius: 30)
    lazy var markerAnimationController = MarkerAnimateController(view: view, projection: mapView.projection)
    lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남
    
    let coreDataLayer: CoreDataManager = CoreDataLayer()
    
    var mapView: NMFMapView { naverMapView.mapView }
    var projection: NMFProjection { naverMapView.mapView.projection }
    var markers = [NMFMarker]()
    var poiData: [POI]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // try? coreDataLayer.removeAll()
        // jsonToData(name: "gangnam_8000")
        // jsonToData(name: "restaurant")
        configureMapView()
    }
    
    private func configureMapView() {
        naverMapView.showZoomControls = true
        mapView.touchDelegate = self
        mapView.addCameraDelegate(delegate: self)
        mapView.moveCamera(.init(scrollTo: startPoint))
        view.addSubview(naverMapView)
    }
    
    private func jsonToData(name: String) {
        guard let path = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: path),
              let jsonResult = try? JSONDecoder().decode(Places.self, from: data)
        else { return }
        
        jsonResult.places.forEach {
            try? coreDataLayer.add(place: $0) {
                try? self.coreDataLayer.save()
            }
        }
    }
    
    func findOptimalClustering(completion: @escaping ([LatLng], [Int]) -> Void) {
        let boundsLatLngs = mapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])
        
        guard let points = try? coreDataLayer.fetch(southWest: southWest,
                                                    northEast: northEast, sorted: true).map({poi in
                                                        LatLng(lat: poi.latitude, lng: poi.longitude)
                                                    }) else { return }
        
        guard !points.isEmpty else { return }
        
        let kRange = (2...10)
        
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
            guard let minKMeans = minKMeans else { return }
            self?.combineClusters(kMeans: minKMeans, clusters: minKMeans.clusters)
            let points = minKMeans.clusters.map({$0.points.size})
            completion(minKMeans.centroids, points)
        }
    }
    
    func combineClusters(kMeans: KMeans, clusters: [Cluster]) {
        let stdDistance: Double = 90     //추후 클러스터 크기에 따라 변동가능성
        
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
        return projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
}

extension ViewController: NMFMapViewCameraDelegate {
    private func createMarker(latLng: LatLng) -> NMFMarker {
        return NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
    
    private func setMapView(makers: [NMFMarker], mapView: NMFMapView?) {
        return markers.forEach { $0.mapView = mapView }
    }
    
    private func createMarkers(latLngs: [LatLng], pointSizes: [Int]) -> [NMFMarker] {
        return zip(latLngs, pointSizes).map { latLng, pointSize in
            let marker = self.createMarker(latLng: latLng)
            guard pointSize != 1 else { return marker }
            marker.setImageView(self.markerImageView, count: pointSize)
            return marker
        }
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        findOptimalClustering(completion: { [weak self] latLngs, pointSizes in
            guard let self = self else { return }
            
            let newMarkers = self.createMarkers(latLngs: latLngs, pointSizes: pointSizes)
            
            guard self.markers.count != 0 else {
                self.setMapView(makers: newMarkers, mapView: self.mapView)
                self.markers = newMarkers
                return
            }
            
            self.setMapView(makers: self.markers, mapView: nil)
            
            self.markerAnimationController.clusteringAnimation(
                old: self.markers.map { $0.position },
                new: newMarkers.map { $0.position },
                isMerge: self.markers.count > newMarkers.count) {
                self.markers = newMarkers
                self.setMapView(makers: self.markers, mapView: self.mapView)
            }
        })
    }
}

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // MARK: - 화면 터치시 마커 찍기
        //        let marker = NMFMarker(position: latlng)
        //        marker.mapView = mapView
    }
}
