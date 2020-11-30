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

protocol MainDisplayLogic: class {
  func displayFetchedCoreData(viewModel: [POI])
}

class MainViewController: UIViewController, MainDisplayLogic {
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

    var interactor: MainBusinessLogic!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureClustering()
        configureMapView()
    }

    private func setup() {
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        self.interactor = interactor
        interactor.presenter = presenter
        presenter.viewController = self
    }

    var displayedCoreData = [POI]()

    func displayFetchedCoreData(viewModel: [POI]) {
        displayedCoreData = viewModel
    }

    private func configureClustering() {
        clustering = Clustering(naverMapView: naverMapView.mapView, coreDataLayer: coreDataLayer)
    }

    private func configureMapView() {
        naverMapView.showZoomControls = true
        mapView.touchDelegate = self
        mapView.addCameraDelegate(delegate: self)
        mapView.moveCamera(.init(scrollTo: startPoint))
        view.addSubview(naverMapView)
    }
}


extension MainViewController: NMFMapViewCameraDelegate {
    private func createMarker(latLng: LatLng) -> NMFMarker {
        return NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }

    private func setMapView(makers: [NMFMarker], mapView: NMFMapView?) {
        return markers.forEach { $0.mapView = mapView }
    }

    private func createMarkers(latLngs: [LatLng], pointSizes: [Int]) -> [NMFMarker] {
        return zip(latLngs, pointSizes).map { latLng, pointSize in
            let marker = self.createMarker(latLng: latLng)
            guard pointSize != 1 else { return marker }
            marker.setImageView(self.markerImageView, count: pointSize)
            return marker
        }
    }

    func mapViewCameraIdle(_ mapView: NMFMapView) {
        clustering?.findOptimalClustering(completion: { [weak self] latLngs, pointSizes, convexHullPoints in
            guard let self = self else { return }

            let newMarkers = self.createMarkers(latLngs: latLngs, pointSizes: pointSizes)

            guard self.markers.count != 0 else {
                self.setMapView(makers: newMarkers, mapView: self.mapView)
                self.markers = newMarkers
                return
            }

            self.setMapView(makers: self.markers, mapView: nil)

            self.markerAnimationController.clusteringAnimation(
                old: self.markers.map { $0.position },
                new: newMarkers.map { $0.position },
                isMerge: self.markers.count > newMarkers.count) {
                self.markers = newMarkers
                self.setMapView(makers: self.markers, mapView: self.mapView)
            }

            self.polygonOverlays.forEach {
                $0.mapView = nil
            }

            self.polygonOverlays.removeAll()

            // MARK: - 영역표시
            for latlngs in convexHullPoints where latlngs.count > 3 {
                let points = latlngs.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }

                let polygon = NMGPolygon(ring: NMGLineString(points: points)) as NMGPolygon<AnyObject>
                guard let polygonOverlay = NMFPolygonOverlay(polygon) else { continue }

                let randomNumber1 = CGFloat(Double.random(in: 0.0...1.0))
                let randomNumber2 = CGFloat(Double.random(in: 0.0...1.0))
                let randomNumber3 = CGFloat(Double.random(in: 0.0...1.0))

                polygonOverlay.fillColor = UIColor(red: randomNumber1,
                                                   green: randomNumber2,
                                                   blue: randomNumber3,
                                                   alpha: 31.0/255.0)
                polygonOverlay.outlineWidth = 3
                polygonOverlay.outlineColor = UIColor(red: 25.0/255.0, green: 192.0/255.0, blue: 46.0/255.0, alpha: 1)
                polygonOverlay.mapView = self.naverMapView.mapView
                self.polygonOverlays.append(polygonOverlay)
            }
        })
    }
}

extension MainViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // MARK: - 화면 터치시 마커 찍기
        //        let marker = NMFMarker(position: latlng)
        //        marker.mapView = mapView
    }
}
