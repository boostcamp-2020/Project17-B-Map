//
//  CSVParser.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/24.
//

import XCTest
@testable import BoostClusteringMaB

class CoreDataLayerMock: CoreDataManager {
    func remove(poi: POI) throws {

    }

    func add(place: Place, completion handler: (() -> Void)?) throws {

    }

    func fetch(sorted: Bool) throws -> [POI] {
        []
    }

    func fetch(by classification: String, sorted: Bool) throws -> [POI] {
        []
    }
    
    func fetch(southWest: LatLng, northEast: LatLng, sorted: Bool) throws -> [POI] {
        return []
    }

    func removeAll() throws {

    }

    func save() throws {

    }
}

class CSVParserTests: XCTestCase {

    func test_convertCSVIntoArray() throws {
        // Given
        let csvParser = CSVParser()

        // When
        try csvParser.convertCSVIntoArray(file: "poi")

        // Then
        XCTAssertNotNil(csvParser.pois)
        XCTAssertTrue(!csvParser.pois.isEmpty)
    }

    func test_add() throws {
        // Given
        let csvParser = CSVParser()
        let coreDataManager: CoreDataManager = CoreDataLayer()
        let beforeCount = try coreDataManager.fetch(sorted: true).count

        // When
        try csvParser.convertCSVIntoArray(file: "poi")
        try csvParser.add(to: coreDataManager)

        // Then
        let afterCount = try coreDataManager.fetch(sorted: true).count
        XCTAssertNotEqual(beforeCount, afterCount)
    }

    func test_add_poi빈배열() {
        // Given
        let csvParser = CSVParser()
        let coreDataManagerMock: CoreDataManager = CoreDataLayerMock()

        // Then
        XCTAssertThrowsError(
            // When
            try csvParser.add(to: coreDataManagerMock)
        )
    }

    func test_convertCSVIntoArray_존재하지않는파일입력() {
        // Given
        let csvParser = CSVParser()

        // Then
        XCTAssertThrowsError(
            // When
            try csvParser.convertCSVIntoArray(file: "존재하지않는파일")
        )
    }
}