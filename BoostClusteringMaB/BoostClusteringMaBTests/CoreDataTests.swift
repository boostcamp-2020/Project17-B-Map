//
//  CoreDataTests.swift
//  BoostClusteringMaBTests
//
//  Created by 현기엽 on 2020/11/23.
//

import XCTest
@testable import BoostClusteringMaB

class CoreDataTests: XCTestCase {
    let newPlace = Place(category: "부스트캠프",
                      id: "123321",
                      imageUrl: nil,
                      name: "Mab",
                      x: "124.323412",
                      y: "35.55532")
    
    func testAddPOI() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        try layer.add(place: newPlace)
        
        // Then
        let poi = try layer.fetch().first(where: { poi -> Bool in
            poi.id == "123321"
        })
        
        XCTAssertEqual(poi?.id, "123321")
        XCTAssertEqual(poi?.category, "부스트캠프")
        XCTAssertEqual(poi?.imageURL, nil)
        XCTAssertEqual(poi?.name, "Mab")
        XCTAssertEqual(poi?.latitude, 35.55532)
        XCTAssertEqual(poi?.longitude, 124.323412)
    }
    
    func testFetchPOI() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try layer.fetch()
        
        // Then
        print(pois)
    }
}
