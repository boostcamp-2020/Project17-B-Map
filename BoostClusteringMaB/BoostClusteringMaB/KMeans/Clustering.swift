//
//  Clustering.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//

import NMapsMap

class Clustering {
	private let naverMapView: NMFMapView
	private let coreDataLayer: CoreDataManager
	
	init(naverMapView: NMFMapView, coreDataLayer: CoreDataManager) {
		self.naverMapView = naverMapView
		self.coreDataLayer = coreDataLayer
	}
	
	func findOptimalClustering(completion: @escaping ([LatLng], [Int], [[LatLng]]) -> Void) {
		
		let boundsLatLngs = naverMapView.coveringBounds.boundsLatLngs
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
			let convexHullPoints = minKMeans.clusters.map { $0.area() }
			completion(minKMeans.centroids, points, convexHullPoints)
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
		let projection = naverMapView.projection
		let point = projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
		return point
	}
}
