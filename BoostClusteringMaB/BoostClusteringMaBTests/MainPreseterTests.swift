//
//  MainPreseterTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/12/17.
//

import XCTest
@testable import BoostClusteringMaB

class MainPreseterTests: XCTestCase {
    // MARK: - Subject Under Test
    var sut: MainPresenter!

    override func setUp() {
        super.setUp()
        setupMainPresenter()
    }

    func setupMainPresenter() {
        sut = MainPresenter()
    }

    class MainDisplayLogicSpy: MainDisplayLogic {
        var isCalled = false

        func displayFetch(viewModel: ViewModel) {
            isCalled = true
        }
    }

    func test_init() throws {
        // Given
        let mainDisplayLogicSpy = MainDisplayLogicSpy()
        sut.viewController = mainDisplayLogicSpy

        // When
        sut.redrawMap([], [], [], [[]])

        // Then
        XCTAssert(mainDisplayLogicSpy.isCalled)
    }
}
