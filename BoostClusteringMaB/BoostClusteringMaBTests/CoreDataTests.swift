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
    
    func testFetchPOIBetweenY30_45X120_135_All() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try layer.fetch(southWest: LatLng(lat: 45, lng: 120), northEast: LatLng(lat: 30, lng: 135))
        
        // Then
        let all = try layer.fetch()
        XCTAssertEqual(pois.count, all.count)
    }
    
    func testFetchPOIBetweenY30_45X135_145_Empty() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try layer.fetch(southWest: LatLng(lat: 45, lng: 135), northEast: LatLng(lat: 30, lng: 145))
        
        // Then
        XCTAssertTrue(pois.isEmpty)
    }
    
    func testFetchPOIBetweenY45_30X120_135_invalidCoordinate() throws {
        // Given
        let layer = CoreDataLayer()
        
        // Then
        XCTAssertThrowsError(try layer.fetch(southWest: LatLng(lat: 30, lng: 120),
                                             northEast: LatLng(lat: 45, lng: 135)))
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
}
