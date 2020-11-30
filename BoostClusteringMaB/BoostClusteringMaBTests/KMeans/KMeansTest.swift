//
//  KMeansTest.swift
//  BoostClusteringMaBTests
//
//  Created by 강민석 on 2020/11/24.
//

import XCTest
@testable import BoostClusteringMaB

class KMeansTest: XCTestCase {  
    // MARK: - Cluster
    
    func test_클러스터_deviation() {
        let center = LatLng(lat: 50, lng: 50)
        let cluster = Cluster(center: center)
        
        let points = [
            LatLng(lat: 10, lng: 10),
            LatLng(lat: 20, lng: 20),
            LatLng(lat: 30, lng: 30),
            LatLng(lat: 40, lng: 40),
            LatLng(lat: 50, lng: 50),
            LatLng(lat: 60, lng: 60)
        ]
        
        points.forEach {
            cluster.add(point: $0)
        }
        
        let result = 25.9272486435
        let errorCoverage = 0.001
        XCTAssertLessThanOrEqual(abs(result - cluster.deviation()), errorCoverage)
    }
}
