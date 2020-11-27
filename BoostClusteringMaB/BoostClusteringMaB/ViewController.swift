//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    lazy var naverMapView = NMFNaverMapView(frame: view.frame)
    lazy var markerImageView = MarkerImageView(radius: 30)
    lazy var markerAnimationController = MarkerAnimateController(view: view, projection: mapView.projection)
    lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남
    
    let coreDataLayer: CoreDataManager = CoreDataLayer()
    
    var mapView: NMFMapView { naverMapView.mapView }
    var projection: NMFProjection { naverMapView.mapView.projection }
    var markers = [NMFMarker]()
    var poiData: [POI]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // try? coreDataLayer.removeAll()
        // jsonToData(name: "gangnam_8000")
        // jsonToData(name: "restaurant")
        configureMapView()
    }
    
    private func configureMapView() {
        naverMapView.showZoomControls = true
        mapView.touchDelegate = self
        mapView.addCameraDelegate(delegate: self)
        mapView.moveCamera(.init(scrollTo: startPoint))
        view.addSubview(naverMapView)
    }
}
