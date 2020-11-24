//
//  LatLng.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import Foundation

struct LatLng {
	
	static let zero: LatLng = LatLng(lat: 0, lng: 0)
	static let greatestFinite: LatLng = LatLng(lat: 1000, lng: 1000)
	
	var lat: Double
	var lng: Double
	
	func squaredDistance(to other: LatLng) -> Double {
		return (self.lat - other.lat) * (self.lat - other.lat) + (self.lng - other.lng) * (self.lng - other.lng)
	}
	
	func distance(to other: LatLng) -> Double {
		return sqrt(squaredDistance(to: other))
	}
}

extension LatLng: Hashable {
	static func == (lhs: LatLng, rhs: LatLng) -> Bool {
		return lhs.lat == rhs.lat && lhs.lng == rhs.lng
	}
	
	static func < (lhs: LatLng, rhs: LatLng) -> Bool {
		return (lhs.lat, lhs.lng) < (rhs.lat, rhs.lng)
	}
	
	static func + (lhs: LatLng, rhs: LatLng) -> LatLng {
		return LatLng(lat: lhs.lat + rhs.lat, lng: lhs.lng + rhs.lng)
	}
	
	static func += (lhs: inout LatLng, rhs: LatLng) {
		lhs = lhs + rhs
	}
}
