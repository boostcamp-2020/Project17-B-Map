//
//  ClusteringTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/28.
//

import XCTest
import NMapsMap
@testable import BoostClusteringMaB

final class MapViewMock: NMFMapViewProtocol {
    var coveringBounds: NMGLatLngBounds
    var projection: NMFProjection

    init(coveringBounds: NMGLatLngBounds, projection: NMFProjection) {
        self.coveringBounds = coveringBounds
        self.projection = projection
    }
}

extension MapViewMock: ClusteringTool {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        return .init(x: latLng.lat, y: latLng.lng)
    }
}

final class NMFProjectionMock: NMFProjection {
    override func point(from coord: NMGLatLng) -> CGPoint {
        return .init(x: coord.lat, y: coord.lng)
    }
}

class ClusterMock: Cluster {
    override func combine(other: Cluster) {
        self.center += other.center
    }

    override func area() -> [LatLng] {
        return [.init(lat: 30, lng: 40),
                .init(lat: 40, lng: 50),
                .init(lat: 50, lng: 60)]
    }
}

final class ClusteringTests: XCTestCase {
    func test_init() {
        // Given
        let coreDataLayerMock = CoreDataLayerMock()

        // When
        let clustering = Clustering(coreDataLayer: coreDataLayerMock)

        // Then
        XCTAssertNotNil(clustering)
    }

    func test_combineClusters() {
        // Given
        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjectionMock())
        let coreDataLayerMock = CoreDataLayerMock()
        let clustering = Clustering(coreDataLayer: coreDataLayerMock)
        clustering.tool = mapViewMock

        let cluster1: [ClusterMock] = [ClusterMock(center: LatLng(lat: 1.0, lng: 1.0)),
                                       ClusterMock(center: LatLng(lat: 90.0, lng: 90.0)),
                                       ClusterMock(center: LatLng(lat: 2.0, lng: 1.0)),
                                       ClusterMock(center: LatLng(lat: 3.0, lng: 1.0)),
                                       ClusterMock(center: LatLng(lat: 4.0, lng: 1.0))]

        // When
        let clusters = clustering.combineClusters(clusters: cluster1)

        // Then
        XCTAssertEqual(clusters.count, 2)
        XCTAssertEqual(clusters.first?.center, LatLng(lat: 10.0, lng: 4.0))
        XCTAssertEqual(clusters.last?.center, LatLng(lat: 90.0, lng: 90.0))
    }
}
