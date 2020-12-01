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

extension NMFMapView: NMFMapViewProtocol { }

protocol MainDisplayLogic: class {
    func displayFetchedCoreData(viewModel: [POI])
}

final class MainViewController: UIViewController, MainDisplayLogic {
    lazy var naverMapView = NMFNaverMapView(frame: view.frame)
    lazy var markerAnimationController: MarkerAnimateController = {
        let controller = MarkerAnimateController(frame: view.frame, markerRadius: 30, mapView: mapView)
        guard let animationView = controller.view else { return controller }
        view.addSubview(animationView)
        return controller
    }()
    lazy var markerImageView = MarkerImageView(radius: markerRadius)
    lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남
    
    let markerRadius: CGFloat = 30
    let coreDataLayer: CoreDataManager = CoreDataLayer()
    
    var polygonOverlays = [NMFPolygonOverlay]()
    var mapView: NMFMapView { naverMapView.mapView }
    var projection: NMFProjection { naverMapView.mapView.projection }
    var markers = [NMFMarker]()
    var poiData: [POI]?
    var clustering: Clustering?
    var interactor: MainBusinessLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        configureClustering()
        clustering?.data = self
        configureMapView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor?.fetchPOI(clustering: clustering)
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

        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(makeMarker(_:)))
        naverMapView.addGestureRecognizer(gestureRecognizer)
        view.addSubview(naverMapView)
    }
    
    @objc func makeMarker(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: view)
        let latlng = point.convert(mapView: mapView)
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: latlng, zoomTo: NMF_MAX_ZOOM - 2)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.8
        mapView.moveCamera(cameraUpdate)
        sender.state = .ended
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showAlert(latlng: latlng)
        }
    }
    
    private func showAlert(latlng: NMGLatLng) {
        let alert = UIAlertController(title: "POI를 추가하시겠습니까?",
                                      message: "OK를 누르면 추가합니다",
                                      preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            let marker = NMFMarker()
            marker.position = latlng
            marker.mapView = self.mapView
            //coreData에 저장시켜 주세요
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
}

extension MainViewController: ClusteringData {
    func redrawMap(_ latLngs: [LatLng], _ pointSizes: [Int], _ bounds: [NMGLatLngBounds], _ convexHulls: [[LatLng]]) {
        let newMarkers = createMarkers(latLngs: latLngs, pointSizes: pointSizes)
        
        guard self.markers.count != 0 else {
            self.configureFirstMarkers(newMarkers: newMarkers, bounds: bounds)
            return
        }

        self.setOveraysMapView(overlays: self.polygonOverlays, mapView: nil)
        //터치 핸들러도 nil로?

        self.markerChangeAnimation(
            newMarkers: newMarkers,
            bounds: bounds,
            completion: {
                self.changePolygonOverays(points: convexHulls)
            })
    }
}

extension MainViewController: NMFMapViewCameraDelegate {
    private func setOveraysMapView(overlays: [NMFOverlay], mapView: NMFMapView?) {
        return overlays.forEach { $0.mapView = mapView }
    }
    
    private func setMarkersBounds(makers: [NMFMarker], bounds: [NMGLatLngBounds]) {
        zip(markers, bounds).forEach { marker, bound in
            marker.touchHandler = { _ in
                self.touchedMarker(bounds: bound, insets: 0)
                return true
            }
        }
    }
    
    private func createMarker(latLng: LatLng) -> NMFMarker {
        return NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
    
    private func createPolygonOverlay(points: [NMGLatLng]) -> NMFPolygonOverlay? {
        let polygon = NMGPolygon(ring: NMGLineString(points: points)) as NMGPolygon<AnyObject>
        guard let polygonOverlay = NMFPolygonOverlay(polygon) else { return nil }
        
        polygonOverlay.fillColor = UIColor(red: CGFloat(.random(in: 0.0...1.0)),
                                           green: CGFloat(.random(in: 0.0...1.0)),
                                           blue: CGFloat(.random(in: 0.0...1.0)),
                                           alpha: 31.0/255.0)
        polygonOverlay.outlineWidth = 3
        polygonOverlay.outlineColor = UIColor(red: 25.0/255.0, green: 192.0/255.0, blue: 46.0/255.0, alpha: 1)
        return polygonOverlay
    }

    private func createMarkers(latLngs: [LatLng], pointSizes: [Int]) -> [NMFMarker] {
        return zip(latLngs, pointSizes).map { latLng, pointSize in
            let marker = self.createMarker(latLng: latLng)
            guard pointSize != 1 else { return marker }
            marker.setImageView(self.markerImageView, count: pointSize)
            return marker
        }
    }
    
    private func touchedMarker(bounds: NMGLatLngBounds, insets: CGFloat) {
        let edgeInsets = UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
        let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: edgeInsets)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.8
        mapView.moveCamera(cameraUpdate)
    }

    func mapViewCameraIdle(_ mapView: NMFMapView) {
        clustering?.findOptimalClustering()
    }

    private func configureFirstMarkers(newMarkers: [NMFMarker], bounds: [NMGLatLngBounds]) {
        self.setOveraysMapView(overlays: newMarkers, mapView: mapView)
        self.setMarkersBounds(makers: newMarkers, bounds: bounds)
        self.markers = newMarkers
    }

    private func markerChangeAnimation(newMarkers: [NMFMarker], bounds: [NMGLatLngBounds], completion: (() -> Void)?) {
        self.setOveraysMapView(overlays: self.markers, mapView: nil)
        let oldMarkers = self.markers
        self.markers = newMarkers

        self.markerAnimationController.clusteringAnimation(
            old: oldMarkers.map { $0.position },
            new: newMarkers.map { $0.position },
            isMerge: oldMarkers.count > newMarkers.count,
            completion: {
                self.setOveraysMapView(overlays: newMarkers, mapView: self.mapView)
                self.setMarkersBounds(makers: newMarkers, bounds: bounds)
                completion?()
            })
    }

    private func changePolygonOverays(points convexHullPoints: [[LatLng]]) {
        polygonOverlays = convexHullPoints
            .filter { $0.count > 3 }
            .compactMap { latlngs in
                let points = latlngs.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }
                return createPolygonOverlay(points: points)
            }

        setOveraysMapView(overlays: polygonOverlays, mapView: mapView)
    }
}

extension MainViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // MARK: - 화면 터치시 마커 찍기
        // let marker = NMFMarker(position: latlng)
        // marker.mapView = mapView
    }
}
