//
//  LinkedListTests.swift
//  BoostClusteringMaBTests
//
//  Created by 강민석 on 2020/11/23.
//

import XCTest
@testable import BoostClusteringMaB

class LinkedListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

	func test_Init() {
		let list = LinkedList<Int>()
		
		list.add(1)
		list.add(2)
		
		XCTAssertEqual(list.size, 2)
	}
	
	func test_PushAndDelete() {
		let list = LinkedList<Int>()
		
		list.add(1)
		list.add(2)
		list.add(3)
		list.add(4)
		list.add(5)
		list.setNowToHead()
		
		XCTAssertEqual(list.now?.value, 1)
		list.moveNowToNext()
		
		XCTAssertEqual(list.now?.value, 2)
		list.moveNowToNext()
		
		XCTAssertEqual(list.now?.value, 3)
		list.moveNowToNext()
		
		XCTAssertEqual(list.now?.value, 4)
		XCTAssertEqual(list.remove(), 4)
		XCTAssertEqual(list.now?.value, 3)
		list.moveNowToNext()
		
		XCTAssertEqual(list.now?.value, 5)
		XCTAssertEqual(list.size, 4)
	}
	
	func test_Sum() {
		let points = LinkedList<LatLng>()
		points.add(LatLng(lat: 10, lng: 10))
		points.add(LatLng(lat: 20, lng: 20))
		points.add(LatLng(lat: 30, lng: 30))
		points.add(LatLng(lat: 40, lng: 40))
		points.add(LatLng(lat: 50, lng: 50))
		
		let zeroCenter = LatLng.zero
		var sum = zeroCenter
		
		points.setNowToHead()
		for _ in 0...points.size {
			sum += (points.now?.value ?? LatLng.zero)
			points.moveNowToNext()
		}
		XCTAssertEqual(sum, LatLng(lat: 150, lng: 150))
	}
}