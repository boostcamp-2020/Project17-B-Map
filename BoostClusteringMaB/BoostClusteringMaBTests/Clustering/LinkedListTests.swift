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
        // Given
        let list = LinkedList<Int>()
        
        // When
        list.add(1)
        list.add(2)
        
        // Then
        XCTAssertEqual(list.size, 2)
    }
    
    func test_리스트가_비었는지() {
        // Given
        let list = LinkedList<Int>()
        
        // Then
        XCTAssertTrue(list.isEmpty)
    }
    
    func test_비었는데_지우면_nil이야() {
        // Given
        let list = LinkedList<Int>()
        
        // Then
        XCTAssertNil(list.remove()) 
    }
    
    func test_PopFront() {
        // Given
        let list = LinkedList<Int>()
        
        // When
        list.add(1)
        list.add(2)
        list.add(3)
        list.add(4)
        list.add(5)
        list.setNowToHead()
        
        //Then
        XCTAssertEqual(list.remove(), 1)
        XCTAssertEqual(list.size, 4)
    }
    
    func test_PopFront를_할때_size가_정상적으로_1줄어드는지() {
        // Given
        let list = LinkedList<Int>()
        list.add(1)
        list.add(2)
        list.add(3)
        
        // When
        list.setNowToHead()
        
        // Then
        XCTAssertEqual(list.size, 3)
        
        // When
        list.remove()
        
        // Then
        XCTAssertEqual(list.size, 2)
    }
    
    func test_list가_하나있을때_PopFront를하면_head와_tail이_nil이_된다() {
        // Given
        let list = LinkedList<Int>()
        
        // When
        list.add(1)
        list.setNowToHead()
        list.remove()
        
        // Then
        XCTAssertNil(list.tail)
        XCTAssertNil(list.head)
    }
    
    func test_PopBack() {
        // Given
        let list = LinkedList<Int>()
        
        // When
        list.add(1)
        list.add(2)
        list.add(3)
        list.add(4)
        list.add(5)
        list.setNowToTail()
        
        // Then
        XCTAssertEqual(list.now, list.tail)
        XCTAssertEqual(list.remove(), 5)
        XCTAssertEqual(list.size, 4)
    }
    
    func test_PopBack을_할때_size가_정상적으로_1줄어드는지() {
        // Given
        let list = LinkedList<Int>()
        
        // When
        list.add(1)
        list.add(2)
        list.add(3)
        
        list.setNowToTail()
        
        // Then
        XCTAssertEqual(list.size, 3)
        
        // When
        list.remove()
        
        // Then
        XCTAssertEqual(list.size, 2)
    }
    
    func test_리스트의_양끝이아닌_요소를_지울때_시나리오() {
        // Given
        let list = LinkedList<Int>()
        
        // When
        list.add(1)
        list.add(2)
        list.add(3)
        list.add(4)
        list.add(5)
        list.setNowToHead()
        
        // Then
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
    
    func test_순회가_잘되는지() {
        // Given
        let points = LinkedList<LatLng>()
        
        // When
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
        
        // Then
        XCTAssertEqual(sum, LatLng(lat: 150, lng: 150))
    }
    
    func test_두개의_list_merge() {
        // Given
        let list = LinkedList<Int>()
        let list2 = LinkedList<Int> ()
        
        // When
        list.add(1)
        list.add(2)
        list.add(3)
        list.add(4)
        
        list2.add(11)
        list2.add(12)
        list2.add(13)
        list2.add(14)
        
        list.merge(other: list2)
        
        // Then
        XCTAssertEqual(list.size, 8)
        
        XCTAssertEqual(list.head?.value, 1)
        XCTAssertEqual(list.tail?.value, 14)
    }
}
