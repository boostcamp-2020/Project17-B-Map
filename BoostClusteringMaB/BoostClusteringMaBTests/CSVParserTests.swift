//
//  CSVParser.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/11/24.
//

import XCTest
@testable import BoostClusteringMaB

class CSVParserTests: XCTestCase {
    func test_parseCSV_poi_count_equal_21() throws {
        // Given
        let csvParser = CSVParser()
        
        timeout(1) { expectation in
            // When
            csvParser.parse(fileName: "poi", completion: { result in
                let places = try? result.get()
                
                // Then
                XCTAssertEqual(places?.count, 21)
                expectation.fulfill()
            })
        }
    }
    
    func test_parseInvalidCSVFile_throws_invalidFileName() throws {
        // Given
        let csvParser = CSVParser()
        
        timeout(1) { expectation in
            // When
            csvParser.parse(fileName: "존재하지_않는_파일", completion: { result in
                do {
                    // Then
                    XCTAssertThrowsError(try result.get())
                    expectation.fulfill()
                } catch {
                    XCTFail("실패")
                }
            })
        }
    }
}
