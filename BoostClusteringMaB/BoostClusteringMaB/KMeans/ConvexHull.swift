//
//  ConvexHull.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/26.
//

import Foundation

class ConvexHull {
	let stdPoint: LatLng
	let points: [LatLng]
	let relativePoints: [LatLng]
	
	init(stdPoint: LatLng, points: [LatLng]) {
		self.stdPoint = stdPoint
		self.points = points
		relativePoints = points
			.dropFirst()
			.map { $0 - stdPoint }
			.sorted(by: {
			if $0.lat * $1.lng != $0.lng * $1.lat {
				return $0.lat * $1.lng < $0.lng * $1.lat
			}
			return ($0.lng, $0.lat) < ($1.lng, $1.lat)
		})
	}
	
	func ccw(point1: LatLng, point2: LatLng, point3: LatLng) -> Int {
		var temp = point1.lng * point2.lat + point2.lng * point3.lat + point3.lng * point1.lat
		temp = temp - point1.lat * point2.lng - point2.lat * point3.lng - point3.lat * point1.lng
		if temp > 0 {
			return 1
		} else if temp < 0 {
			return -1
		}
		return 0
	}
	
	func run() -> [LatLng] {
		var stack = [Int]()
		stack.append(0)
		stack.append(1)
		
		var next: Int = 2
		
		while next < points.count {
			while stack.count >= 2 {
				guard let second = stack.popLast(), let first = stack.last else { return [] }
				
				if ccw(point1: points[first], point2: points[second], point3: points[next]) > 0 {
					stack.append(second)
					break
				}
			}
			stack.append(next)
			next += 1
		}
		var result = stack.map { points[$0] }
		result.append(points[0])
		return result
	}
}
