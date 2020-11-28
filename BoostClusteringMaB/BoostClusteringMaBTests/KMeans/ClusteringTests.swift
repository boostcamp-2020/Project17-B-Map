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

class ClusteringTests: XCTestCase {
    func test_init() {
        // Given
        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjection())
        let coreDataLayerMock = CoreDataLayerMock()

        // When
        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: coreDataLayerMock)

        // Then
        XCTAssertNotNil(clustering)
    }

    func test_init() {
        // Given
        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjection())
        let coreDataLayerMock = CoreDataLayerMock()

        // When
        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: coreDataLayerMock)

        // Then
        XCTAssertNotNil(clustering)
    }

}
