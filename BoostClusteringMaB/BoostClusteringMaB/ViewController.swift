//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {

	var mapView: NMFMapView!
	var markers = [NMFMarker]()
	var poiData: POI?
	typealias POIValue = (Int, (Double, Double))

	override func viewDidLoad() {
		super.viewDidLoad()
		poiData = jsonToData(name: "gangnam_8000")
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		mapView = NMFMapView(frame: view.frame)
		mapView.addCameraDelegate(delegate: self)
		view.addSubview(mapView)

		let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587)) // 강남
		//let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.56295485320913, lng: 126.99235958053829)) // 을지로
		mapView.moveCamera(cameraUpdate)
	}
	
	func marker(latLng: LatLng) {
		let marker = NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
		marker.mapView = mapView
		markers.append(marker)
	}

	private func jsonToData(name: String) -> POI? {
		if let path = Bundle.main.url(forResource: name, withExtension: "json") {
			guard let data = try? Data(contentsOf: path) else { return nil }
			let jsonResult = try? JSONDecoder().decode(POI.self, from: data)
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

	func findOptimalClustering() {
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
		print(index)
		
		let min = index.dropFirst().min()
		guard let optimalKIndex = index.firstIndex(where: { $0 == min }) else { return }
		
		let kMeans = KMeans(k: optimalKIndex + 1, points: sortedPoints)
		kMeans.run()
		combineClusters(kMeans: kMeans, clusters: kMeans.clusters)
		
		print("count \(kMeans.clusters.count)")
		kMeans.clusters.forEach {
			print($0.points.size)
		}
		kMeans.centroids.forEach {
			print($0)
			marker(latLng: $0)
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
		let projection = mapView.projection
		let point = projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
		return point
	}
}

extension ViewController: NMFMapViewCameraDelegate {
	func mapViewCameraIdle(_ mapView: NMFMapView) {

        markers.forEach({
            $0.mapView = nil
        })

		self.findOptimalClustering()
	}
}

extension NMFMarker {
    func setMarker(_ view: UIView) {
        self.iconImage = NMFOverlayImage(image: view.snapshot())
    }
}

extension UIView {
    /// View를 UIImage로 생성
    ///
    /// 지정한 view를 이미지로 만들어줌
    /// ```
    /// let uiImage: UIImage = view.snapshot()
    /// ```
    /// - Returns: UIImage()
    func snapshot(_ view: UIView...) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, UIScreen.main.scale)
        guard let currentContext = UIGraphicsGetCurrentContext() else { return UIImage() }
        self.layer.render(in: currentContext)
        guard let img = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        UIGraphicsEndImageContext()
        return img
    }
}
