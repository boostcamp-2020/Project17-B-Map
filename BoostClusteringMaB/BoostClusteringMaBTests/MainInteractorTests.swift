//
//  MainInteractorTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/12/17.
//

import XCTest
@testable import BoostClusteringMaB

class MainInteractorTests: XCTestCase {
    // MARK: - Subject Under Test
    var sut: MainInteractor!

    override func setUp() {
        super.setUp()
        setupMainInteractor()
    }

    func setupMainInteractor() {
        sut = MainInteractor()
    }

    class MainPresentationLogicSpy: MainPresentationLogic, ClusteringData {
        var isCalled = false

        func redrawMap(_ latLngs: [LatLng],
                       _ pointCount: [Int],
                       _ bounds: [(southWest: LatLng, northEast: LatLng)],
                       _ convexHulls: [[LatLng]]) {
            isCalled = true
        }
    }

    class ClusteringMock: ClusteringService {
        var data: ClusteringData?
        var tool: ClusteringTool?

        var isCalled = false

        func findOptimalClustering(southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
            data?.redrawMap([], [], [], [[]])
            isCalled = true
        }

        func combineClusters(clusters: [Cluster]) -> [Cluster] {
            return []
        }
    }

    func test_Interactor_Clustering_init() throws {
        XCTAssertNotNil(sut.clustering)
    }

    func test_findOptimalClustering() throws {
        // Given
        let clusteringMock = ClusteringMock()
        sut.clustering = clusteringMock

        let mainPresentationLogicSpy = MainPresentationLogicSpy()
        sut.presenter = mainPresentationLogicSpy

        // When
        sut.fetchPOI(southWest: .zero, northEast: .zero, zoomLevel: 0.0)

        // Then
        XCTAssert(clusteringMock.isCalled)
    }

    func test_fetchPOI() throws {
        // Given
        let clusteringMock = ClusteringMock()
        sut.clustering = clusteringMock

        let mainPresentationLogicSpy = MainPresentationLogicSpy()
        sut.presenter = mainPresentationLogicSpy

        clusteringMock.data = mainPresentationLogicSpy

        // When
        sut.fetchPOI(southWest: .zero, northEast: .zero, zoomLevel: 0.0)

        // Then
        XCTAssert(mainPresentationLogicSpy.isCalled)
    }
}
