//
//  ClusteringTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/28.
//

import XCTest
import NMapsMap
@testable import BoostClusteringMaB

class MapViewMock: NMFMapViewProtocol {
    var coveringBounds: NMGLatLngBounds
    var projection: NMFProjection

    init(coveringBounds: NMGLatLngBounds, projection: NMFProjection) {
        self.coveringBounds = coveringBounds
        self.projection = projection
    }
}

class NMFProjectionMock: NMFProjection {
    override func point(from coord: NMGLatLng) -> CGPoint {
        return CGPoint(x: coord.lat, y: coord.lng)
    }
}

class ClusteringTests: XCTestCase {
    func test_init() {
        // Given
        let coreDataLayerMock = CoreDataLayerMock()

        // When
        let clustering = Clustering(coreDataLayer: coreDataLayerMock)

        // Then
        XCTAssertNotNil(clustering)
    }
}
