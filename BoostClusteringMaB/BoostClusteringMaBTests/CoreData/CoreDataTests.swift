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
        
        timeout(1) { expectation in
            // When
            layer.add(place: newPlace) { _ in
                layer.fetch { result in
                    // Then
                    let poi = try? result.get().first
                    XCTAssertEqual(poi?.id, "123321")
                    XCTAssertEqual(poi?.category, "부스트캠프")
                    XCTAssertEqual(poi?.imageURL, nil)
                    XCTAssertEqual(poi?.name, "Mab")
                    XCTAssertEqual(poi?.latitude, 35.55532)
                    XCTAssertEqual(poi?.longitude, 124.323412)
                    expectation.fulfill()
                }
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
        
        timeout(1) { expectation in
            // When
            layer.add(place: wrongCoordinatePlace) { result in
                // Then
                XCTAssertNil(try? result.get())
                expectation.fulfill()
            }
        }
    }
    
    func testFetchPOI() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        layer.fetch { pois in
            // Then
            let poi = try? pois.get()
            XCTAssertNotNil(poi)
        }
    }
    
    func testFetchPOIBetweenY30_45X120_135_All() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        layer.fetch(southWest: LatLng(lat: 30, lng: 120),
                    northEast: LatLng(lat: 45, lng: 135)) { pois in
            layer.fetch { all in
                // Then
                let poisCount = try? pois.get().count
                let allCount = try? all.get().count
                XCTAssertEqual(poisCount, allCount)
                XCTAssertNotNil(poisCount)
            }
        }
    }
    
    func testFetchPOIBetweenY30_45X135_145_Empty() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        layer.fetch(southWest: LatLng(lat: 30, lng: 135), northEast: LatLng(lat: 45, lng: 145)) { pois in
            // Then
            guard let bool = try? pois.get().isEmpty else {
                XCTFail("Try failure")
                return
            }
            XCTAssertTrue(bool)
        }
    }
    
    func testFetchPOIBetweenY45_30X120_135_invalidCoordinate() throws {
        // Given
        let layer = CoreDataLayer()

        // When
        layer.fetch(southWest: LatLng(lat: 45, lng: 120), northEast: LatLng(lat: 30, lng: 135)) { pois in
            // Then
            XCTAssertNil(try? pois.get())
        }
    }
    
    func test_CoreDataManager_fetchByClassification() {
        // Given
        let layer = CoreDataLayer()
        
        // When
        layer.fetch(by: "부스트캠프") { result in
            switch result {
            case .success(let pois):
                XCTAssertTrue(pois.allSatisfy({ poi -> Bool in
                    poi.category == "부스트캠프"
                }))
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
    }
    
    func testAdd10000POI() throws {
        timeout(40) { expectation in
            // Given
            let numberOfRepeats = 10000
            let layer = CoreDataLayer()
            let places = (0..<numberOfRepeats).map { _ in newPlace }
            var beforeCount: Int = 0
            
            layer.fetch { result in
                guard let count = try? result.get().count else {
                    XCTFail("before count is nil")
                    return
                }
                beforeCount = count
            }
            
            // When
            layer.add(places: places) { _ in
                layer.fetch { result in
                    guard let afterCount = try? result.get().count else {
                        XCTFail("after count is nil")
                        return
                    }
                    
                    // Then
                    XCTAssertEqual(beforeCount + numberOfRepeats, afterCount)
                    expectation.fulfill()
                }
            }
        }
    }
    
    func testRemove() throws {
        // Given
        let layer = CoreDataLayer()
        layer.add(place: newPlace) { _ in
            layer.fetch { result in
                let pois = try? result.get()
                guard let poi = pois?.first(where: { poi -> Bool in
                    poi.id == self.newPlace.id
                }),
                let beforeCount = pois?.count else {
                    XCTFail("data add fail")
                    return
                }
                
                // When
                layer.remove(poi: poi) { _ in }
                
                // Then
                layer.fetch { afterResult in
                    let afterCount = try? afterResult.get().count
                    XCTAssertEqual(beforeCount - 1, afterCount)
                }
            }
        }
    }
//
    func testRemoveAll() throws {
        // Given
        let layer = CoreDataLayer()
        
        // When
        timeout(1) { expectation in
            layer.removeAll { _ in
                // Then
                layer.fetch { result in
                    switch result {
                    case .success(let pois):
                        XCTAssertTrue(pois.isEmpty)
                        expectation.fulfill()
                    case .failure(let error):
                        XCTFail(error.localizedDescription)
                    }
                }
            }
            
        }
    }
}
