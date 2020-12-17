//
//  MainViewControllerTests.swift
//  BoostClusteringMaBTests
//
//  Created by ParkJaeHyun on 2020/12/17.
//

import XCTest
@testable import BoostClusteringMaB

class MainViewControllerTests: XCTestCase {
    // MARK: - Subject Under Test
    var sut: MainViewController!
    var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow()
        setupViewController()
    }

    func setupViewController() {
        let bundle = Bundle.main
        let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        sut = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
    }

    func loadView() {
        window.addSubview(sut.view)
        RunLoop.current.run(until: Date())
    }

    class MainBusinessLogicSpy: MainBusinessLogic {

        var isCalled = false

        func fetchPOI(southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
            isCalled = true
        }

        func addLocation(_ latlng: LatLng, southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
            isCalled = true
        }

        func deleteLocation(_ latlng: LatLng, southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
            isCalled = true
        }
    }

    func test_viewDidAppear_bringSubviewToFront() {
        // Given
        loadView()

        // When
        sut.viewDidAppear(true)

        // Then
        let subViews: [UIView?] = sut.view.subviews.suffix(3)
        let compareSubViews = [sut.bottomSheetViewController.switchButton,
                               sut.bottomSheetViewController.view,
                               sut.drawerController.view]

        XCTAssertEqual(subViews[0], compareSubViews[0],
                       "bottomSheetViewController.switchButton가 sut.view중에서 세번째 있어야 합니다.")

        XCTAssertEqual(subViews[1], compareSubViews[1],
                       "bottomSheetViewController.view가 sut.view중에서 두번째 있어야 합니다.")

        XCTAssertEqual(subViews[2], compareSubViews[2],
                       "bottomSheetViewController.view가 sut.view중에서 첫번째 있어야 합니다.")
    }

    func test_mapViewCameraIdle() {
        // Given
        let mainBusinessLogicSpy = MainBusinessLogicSpy()

        // When
        loadView()
        sut.interactor = mainBusinessLogicSpy
        sut.mapViewCameraIdle(.init(frame: .zero))
        
        // Then
        XCTAssert(mainBusinessLogicSpy.isCalled, "init이 되면 BusineesLogic이 불려야 합니다.")
    }
}
