//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

protocol NMFMapViewProtocol {
    var coveringBounds: NMGLatLngBounds { get }
    var projection: NMFProjection { get }
}

extension NMFMapView: NMFMapViewProtocol {

}

class ViewController: UIViewController {
    lazy var naverMapView = NMFNaverMapView(frame: view.frame)
    lazy var markerAnimationController = MarkerAnimateController(view: view, projection: mapView.projection)
    lazy var markerImageView = MarkerImageView(radius: 30)
    lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남

    let coreDataLayer: CoreDataManager = CoreDataLayer()

    var polygonOverlays = [NMFPolygonOverlay]()
    var mapView: NMFMapView { naverMapView.mapView }
    var projection: NMFProjection { naverMapView.mapView.projection }
    var markers = [NMFMarker]()
    var poiData: [POI]?
    var clustering: Clustering?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureClustering()
    }

    private func configureClustering() {
        let points = settingPoints()
        clustering = Clustering(naverMapView: naverMapView.mapView, points: points)
    }

    func settingPoints() -> [LatLng] {
        let boundsLatLngs = naverMapView.mapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])

        guard let fetchPoints = try? coreDataLayer.fetch(southWest: southWest,
                                                         northEast: northEast,
                                                         sorted: true) else { return [] }

        return fetchPoints.map({poi in LatLng(lat: poi.latitude, lng: poi.longitude)})
    }

    private func configureMapView() {
        naverMapView.showZoomControls = true
        mapView.touchDelegate = self
        mapView.addCameraDelegate(delegate: self)
        mapView.moveCamera(.init(scrollTo: startPoint))
        view.addSubview(naverMapView)
    }
}
