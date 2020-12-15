//
//  ConvexHullTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/26.
//

import XCTest
@testable import BoostClusteringMaB

final class ConvexHullTests: XCTestCase {
    
    func test_ConvexHull() {
        
        // Given
        var points: [LatLng] = []

        points.append(LatLng(lat: 0.0, lng: 0.0))
        points.append(LatLng(lat: 0.0, lng: 1.0))
        points.append(LatLng(lat: 1.0, lng: 0.0))
        points.append(LatLng(lat: 1.0, lng: 1.0))
        points.append(LatLng(lat: 0.6, lng: 0.7))

        // When
        let convex = ConvexHull(poiPoints: points)

        // Then
        XCTAssertEqual(convex.run().count, 5)
        
    }
}
