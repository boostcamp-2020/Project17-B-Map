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

class ClusteringTests: XCTestCase {
//    func settingPoints(_ mapView: MapViewMock, _ coreDataLayer: CoreDataLayerMock) -> [LatLng] {
//        let boundsLatLngs = mapView.coveringBounds.boundsLatLngs
//        let southWest = LatLng(boundsLatLngs[0])
//        let northEast = LatLng(boundsLatLngs[1])
//
//        coreDataLayer.fetch(southWest: southWest,
//                            northEast: northEast,
//                            sorted: true) { fetchPoints in
//            return fetchPoints.map({poi in LatLng(lat: poi.latitude, lng: poi.longitude)})
//        }
//    }

    func test_init() {
        // Given
        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjection())
        let coreDataLayerMock = CoreDataLayerMock()

        // When
        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: coreDataLayerMock)

        // Then
        XCTAssertNotNil(clustering)
    }

    func test_convertLatLngToPoint() {
        // Given
        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjectionMock())
        let coreDataLayerMock = CoreDataLayerMock()

        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: coreDataLayerMock)

        // When
        let point = clustering.convertLatLngToPoint(latLng: .init(lat: 30, lng: 50))

        // Then
        XCTAssertEqual(point.x, 30)
        XCTAssertEqual(point.y, 50)
    }

//    func test_convertLatLngToPoint_NMGWebMercatorCoord() {
//        // Given
//        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjectionMock())
//        let coreDataLayerMock = CoreDataLayerMock()
//        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: coreDataLayerMock)
//
//        // When
//        let point = clustering.convertLatLngToPoint(latLng1: .zero, latLng2: .zero)
//
//        // Then
//        XCTAssertEqual(point.x, 30)
//        XCTAssertEqual(point.y, 50)
//    }

    func test_combineClusters() {
        // Given
        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjectionMock())
        let coreDataLayerMock = CoreDataLayerMock()
        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: coreDataLayerMock)

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

    // MARK: - 보류
//    func test_findOptimalClustering() {
//        // Given
//        let expectaion = expectation(description: "completed")
//        let mapViewMock = MapViewMock(coveringBounds: NMGLatLngBounds(), projection: NMFProjection())
//        let clustering = Clustering(naverMapView: mapViewMock, coreDataLayer: CoreDataLayerMock())
//
//        // When
//        clustering.findOptimalClustering {latLngs, pointSizes, convexHullPoints in
//            // Then
//            XCTAssertEqual(latLngs.count, 1)
//            XCTAssertEqual(pointSizes.count, 1)
//            XCTAssertEqual(convexHullPoints.count, 3)
//
//            expectaion.fulfill()
//        }
//
//        waitForExpectations(timeout: 60)
//    }
}
