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
        try layer.add(place: newPlace) {
            do {
                try? layer.save()

                // Then
                let poi = try layer.fetch().first(where: { poi -> Bool in
                    poi.id == self.newPlace.id
                })

                XCTAssertEqual(poi?.id, "123321")
                XCTAssertEqual(poi?.category, "부스트캠프")
                XCTAssertEqual(poi?.imageURL, nil)
                XCTAssertEqual(poi?.name, "Mab")
                XCTAssertEqual(poi?.latitude, 35.55532)
                XCTAssertEqual(poi?.longitude, 124.323412)
            } catch {
                
            }
        }
    }
    
    func test_add_잘못된좌표를입력_invalidCoordinate() throws {
        // Given
        let layer = CoreDataLayer()
        let wrongCoordinatePlace = Place(id: "아이디",
                                         name: "이름",
                                         x: "경도",
                                         y: "위도",
                                         imageURL: nil,
                                         category: "카테고리")
        
        // Then
        XCTAssertThrowsError(
            // When
            try layer.add(place: wrongCoordinatePlace) {
                try? layer.save()
            })
        
    }
    
    func testFetchPOI() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try layer.fetch()
        
        // Then
        XCTAssertNotNil(pois)
    }
    
    func testFetchPOIBetweenY30_45X120_135_All() throws {
        // Given
        let layer = CoreDataLayer()
        var places = [Place]()
        (0...100).forEach({ _ in
            places.append(newPlace)
        })

        try? layer.add(places: places) {
            do {
                try layer.save()
                // When
                let pois = try layer.fetch(southWest: LatLng(lat: 30, lng: 120), northEast: LatLng(lat: 45, lng: 135))

                // Then
                let all = try layer.fetch()
                XCTAssertEqual(pois.count, all.count)
            } catch {

            }
        }
    }
    
    func testFetchPOIBetweenY30_45X135_145_Empty() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try layer.fetch(southWest: LatLng(lat: 30, lng: 135), northEast: LatLng(lat: 45, lng: 145))
        
        // Then
        XCTAssertTrue(pois.isEmpty)
    }
    
    func testFetchPOIBetweenY45_30X120_135_invalidCoordinate() throws {
        // Given
        let layer = CoreDataLayer()
        
        // Then
        XCTAssertThrowsError(try layer.fetch(southWest: LatLng(lat: 45, lng: 120),
                                             northEast: LatLng(lat: 30, lng: 135)))
    }
    
    func testAdd10000POI() throws {
        try timeout(60) { expectation in
            // Given
            let numberOfRepeats = 10000
            let layer = CoreDataLayer()

            let beforeCount = try layer.fetch().count
            let group = DispatchGroup()

            // When
            for _ in 0..<numberOfRepeats {
                group.enter()
                try? layer.add(place: newPlace) {
                    group.leave()
                }
            }

            // Then
            group.notify(queue: .main) {
                try? layer.save()
                let fetchLayer = CoreDataLayer()
                let afterCount = try? fetchLayer.fetch().count
                XCTAssertEqual(beforeCount + numberOfRepeats, afterCount)
                expectation.fulfill()
            }
        }
    }
    
    func test_CoreDataManager_fetchByClassification() {
        // Given
        let layer = CoreDataLayer()
        
        // When
        let pois = try? layer.fetch(by: "부스트캠프")
        
        // Then
        pois?.forEach({
            XCTAssertEqual($0.category, "부스트캠프")
        })
    }
    
    func testRemove() throws {
        // Given
        let layer = CoreDataLayer()
        try layer.add(place: newPlace) {            
            do {
                let pois = try layer.fetch()
                guard let poi = pois.first(where: { poi -> Bool in
                    poi.id == self.newPlace.id
                }) else {
                    XCTFail("data add fail")
                    return
                }
                let beforeCount = pois.count
                
                // When
                layer.remove(poi: poi)
                try layer.save()
                
                // Then
                let afterCount = try layer.fetch().count
                XCTAssertEqual(beforeCount - 1, afterCount)
            } catch {}
        }
    }
    
    func testRemoveAll() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        try layer.removeAll()
        try layer.save()
        
        // Then
        XCTAssertTrue(try layer.fetch().isEmpty)
    }
}
