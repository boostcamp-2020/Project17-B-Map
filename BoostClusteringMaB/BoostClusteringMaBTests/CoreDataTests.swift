//
//  CoreDataTests.swift
//  BoostClusteringMaBTests
//
//  Created by 현기엽 on 2020/11/23.
//

import XCTest
import CoreData
@testable import BoostClusteringMaB

class CoreDataTests: XCTestCase {
    let newPlace = Place(id: "123321",
                         name: "Mab",
                         x: "124.323412",
                         y: "35.55532",
                         imageURL: nil,
                         category: "부스트캠프")
    
    func testAddPOI() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        try layer.add(place: newPlace)
        
        // Then
        let poi = try layer.fetch().first(where: { poi -> Bool in
            poi.id == newPlace.id
        })
        
        XCTAssertEqual(poi?.id, newPlace.id)
        XCTAssertEqual(poi?.category, newPlace.category)
        XCTAssertEqual(poi?.imageURL, newPlace.imageURL)
        XCTAssertEqual(poi?.name, newPlace.name)
        XCTAssertEqual(poi?.latitude, Double(newPlace.y))
        XCTAssertEqual(poi?.longitude, Double(newPlace.x))
    }
    
    func testFetchPOI() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try layer.fetch()
        
        // Then
        XCTAssertNotNil(pois)
        print(pois.count)
    }
    
    func testAdd10000POI() throws {
        try timeout(30) { expectation in
            // Given
            let numberOfRepeats = 10000
            let layer = CoreDataLayer()
            let beforeCount = try layer.fetch().count
            let group = DispatchGroup()
            
            // When
            for _ in 0..<numberOfRepeats {
                group.enter()
                try? layer.add(place: newPlace) {
                    try? layer.save()
                    group.leave()
                }
            }
            
            // Then
            group.notify(queue: .main) {
                let fetchLayer = CoreDataLayer()
                let afterCount = try? fetchLayer.fetch().count
                XCTAssertEqual(beforeCount + numberOfRepeats, afterCount)
                CoreDataContainer.shared.saveContext()
                expectation.fulfill()
            }
        }
    }

    func test_CoreDataManager_fetchByClassification() {
        //Given
        let layer = CoreDataLayer()

        //When
        let pois = try? layer.fetch(by: "부스트캠프")

        //Then
        pois?.forEach({
            XCTAssertEqual($0.category, "부스트캠프")
        })
    }
}
