//
//  CSVParser.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/24.
//

import XCTest
@testable import BoostClusteringMaB

class CSVParserTests: XCTestCase {

    func test_CSVParser_convertCSVIntoArray() throws {
        // Given
        let csvParser = CSVParser()

        // When
        csvParser.convertCSVIntoArray(file: "poi")

        // Then
        XCTAssertNotNil(csvParser.pois)
        XCTAssertTrue(!csvParser.pois.isEmpty)
    }

    func test_CSVParser_add() throws {
        // Given
        let csvParser = CSVParser()
        let coreDataManager: CoreDataManager = CoreDataLayer()
        let beforeCount = try coreDataManager.fetch().count

        // When
        csvParser.convertCSVIntoArray(file: "poi")
        try csvParser.add(to: coreDataManager)

        // Then
        let afterCount = try coreDataManager.fetch().count
        XCTAssertNotEqual(beforeCount, afterCount)
    }
}
