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
    var markers = [NMFMarker]()
    var poiData: Places?
    
    let markerImageView = MarkerImageView(radius: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        poiData = jsonToData(name: "gangnam_8000")
        markers = findOptimalClustering().map { addMarker(latLng: .init(lat: $0.lat, lng: $0.lng)) }
        markers.forEach { $0.mapView = naverMapView }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        naverMapView.addCameraDelegate(delegate: self)
        view.addSubview(naverMapView)
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

    private func jsonToData(name: String) -> Places? {
        if let path = Bundle.main.url(forResource: name, withExtension: "json") {
            guard let data = try? Data(contentsOf: path) else { return nil }
            let jsonResult = try? JSONDecoder().decode(Places.self, from: data)
            return jsonResult
        }
        return nil
    }

    func generatePoints() -> [LatLng] {
        guard let xList = poiData?.places.compactMap({Double($0.x)}) else { return [] }
        guard let yList = poiData?.places.compactMap({Double($0.y)}) else { return [] }

        var points = [LatLng]()
        for (x, y) in zip(xList, yList) {
            points.append(LatLng(lat: y, lng: x))
        }
        return points
    }

    func findOptimalClustering() -> [LatLng] {
        let points = generatePoints()
        let sortedPoints = points.sorted(by: <)

        let minK = 1
        let maxK = 8
        var index: [Double] = []
        (minK...maxK).forEach {
            let kMeans = KMeans(k: $0, points: sortedPoints)
            kMeans.run()
            index.append(kMeans.daviesBouldinIndex())
        }
//        print(index)

        let min = index.dropFirst().min()
        guard let optimalKIndex = index.firstIndex(where: { $0 == min }) else { return [] }

        let kMeans = KMeans(k: optimalKIndex + 1, points: sortedPoints)
        kMeans.run()
        combineClusters(kMeans: kMeans, clusters: kMeans.clusters)

//        print("count \(kMeans.clusters.count)")
        kMeans.clusters.forEach {
            print($0.points.size)
        }
        return kMeans.centroids
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
}

extension ViewController: NMFMapViewCameraDelegate {
    enum ClustringAnimationType {
        case merge, divide
    }

    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let newMarkers = self.findOptimalClustering().map {
            self.addMarker(latLng: $0)
        }

        if markers.count > newMarkers.count {
            markerClustringAnimation(.merge, newMarkers)
        } else if markers.count < newMarkers.count {
            markerClustringAnimation(.divide, newMarkers)
        }
    }

    private func markerClustringAnimation(_ type: ClustringAnimationType, _ newMarkers: [NMFMarker]) {
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
                lowerMarker.moveWithAnimation(naverMapView, to: .init(lat: lat, lng: lng)) {
                    lowerMarker.mapView = nil
                }

            case .divide:
                let lat = lowerMarker.position.lat
                let lng = lowerMarker.position.lng
                lowerMarker.position = .init(lat: nearestMarker.position.lat,
                                             lng: nearestMarker.position.lng)
                lowerMarker.mapView = naverMapView
                lowerMarker.moveWithAnimation(naverMapView, to: .init(lat: lat, lng: lng), complete: nil)
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
