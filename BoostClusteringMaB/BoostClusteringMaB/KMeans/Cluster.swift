//
//  Cluster.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import Foundation

class Cluster: Equatable {
	static func == (lhs: Cluster, rhs: Cluster) -> Bool {
		return lhs.center == rhs.center
	}
	
	var center: LatLng
	var points: LinkedList<LatLng>
	
	init(center: LatLng) {
		self.center = center
		self.points = LinkedList<LatLng>()
	}
	
	func add(point: LatLng) {
		points.add(point)
	}
	
	@discardableResult
	func remove(point: LatLng) -> LatLng? {
		return points.remove()
	}
	
	func updateCenter() {
		var newCenter = LatLng.zero
		
		points.setNowToHead()
		for _ in 0..<points.size {
			newCenter = newCenter + (points.now?.value ?? LatLng.zero)
			points.moveNowToNext()
		}
		newCenter.lat /= Double(points.size)
		newCenter.lng /= Double(points.size)
		
		center = newCenter
	}
	
	func combine(other: Cluster) {
		self.points.merge(other: other.points)
		updateCenter()
	}
	
	// 오차 제곱 합
	func sumOfSquaredOfError() -> Double {
		var sum: Double = 0
		points.setNowToHead()
		for _ in 0..<points.size {
			sum += center.squaredDistance(to: (points.now?.value ?? LatLng.zero))
			points.moveNowToNext()
		}
		return sum
	}
	
	//중심점과 클러스터내의 점들간의 거리의 평균
	func deviation() -> Double {
		var sum: Double = 0
		points.setNowToHead()
		for _ in 0..<points.size {
			sum += center.distance(to: (points.now?.value ?? LatLng.zero))
			points.moveNowToNext()
		}
		let result = sum / Double(points.size)
		return result
	}
}
