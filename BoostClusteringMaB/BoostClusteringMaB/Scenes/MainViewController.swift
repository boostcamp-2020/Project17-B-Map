//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

protocol ClusteringTool: class {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint
}

protocol ClusteringData: class {
    func redrawMap(_ latLngs: [LatLng],
                   _ pointSizes: [Int],
                   _ bounds: [(southWest: LatLng, northEast: LatLng)],
                   _ convexHulls: [[LatLng]])
}

protocol NMFMapViewProtocol {
    var coveringBounds: NMGLatLngBounds { get }
    var projection: NMFProjection { get }
}

extension NMFMapView: NMFMapViewProtocol { }

protocol MainDisplayLogic: class {
    func displayFetch(viewModel: ViewModel)
}

final class MainViewController: UIViewController {
    lazy var naverMapView = NMFNaverMapView(frame: view.frame)
    lazy var markerAnimationController: MarkerAnimateController = {
        let controller = MarkerAnimateController(frame: view.frame, markerRadius: 30, mapView: mapView)
        guard let animationView = controller.view else { return controller }
        view.addSubview(animationView)
        return controller
    }()
    lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남
    
    var displayedData: ViewModel?
    
    var interactor: MainBusinessLogic?
    var mapView: NMFMapView { naverMapView.mapView }
    var projection: NMFProjection { naverMapView.mapView.projection }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVIP()
        configureMapView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: NSNotification.Name(rawValue: "Notify"), object: nil)
    }

    
    // MARK: - configure VIP
    private func configureVIP() {
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        self.interactor = interactor
        interactor.presenter = presenter
        interactor.clustering?.tool = self
        interactor.clustering?.data = presenter
        presenter.viewController = self
    }
    
    private func configureMapView() {
        naverMapView.showZoomControls = true
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

extension MainViewController: MainDisplayLogic {
    func displayFetch(viewModel: ViewModel) {
        let oldViewModel = displayedData
        displayedData = viewModel
        redrawMap(oldViewModel: oldViewModel, newViewModel: viewModel)
    }
    
    private func redrawMap(oldViewModel: ViewModel?, newViewModel: ViewModel) {
        guard let oldViewModel = oldViewModel else {
            self.configureFirstMarkers(newMarkers: newViewModel.markers, bounds: newViewModel.bounds)
            return
        }

        self.setOveraysMapView(overlays: oldViewModel.polygons, mapView: nil)

        self.markerChangeAnimation(
            oldMarkers: oldViewModel.markers,
            newMarkers: newViewModel.markers,
            bounds: newViewModel.bounds,
            completion: {
                self.setOveraysMapView(overlays: newViewModel.polygons, mapView: self.mapView)
            })
    }
}

private extension MainViewController {
    func configureFirstMarkers(newMarkers: [NMFMarker], bounds: [NMGLatLngBounds]) {
        self.setOveraysMapView(overlays: newMarkers, mapView: mapView)
        self.setMarkersBounds(markers: newMarkers, bounds: bounds)
    }
    
    func setOveraysMapView(overlays: [NMFOverlay], mapView: NMFMapView?) {
        return overlays.forEach { $0.mapView = mapView }
    }
    
    func setMarkersBounds(markers: [NMFMarker], bounds: [NMGLatLngBounds]) {
        zip(markers, bounds).forEach { marker, bound in
            marker.touchHandler = { _ in
                self.touchedMarker(bounds: bound, insets: 0)
                return true
            }
        }
    }
    
    func touchedMarker(bounds: NMGLatLngBounds, insets: CGFloat) {
        let edgeInsets = UIEdgeInsets(top: insets, left: insets, bottom: insets, right: insets)
        let cameraUpdate = NMFCameraUpdate(fit: bounds, paddingInsets: edgeInsets)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.8
        mapView.moveCamera(cameraUpdate)
    }
    
    func markerChangeAnimation(oldMarkers: [NMFMarker],
                               newMarkers: [NMFMarker],
                               bounds: [NMGLatLngBounds],
                               completion: (() -> Void)?) {
        self.setOveraysMapView(overlays: oldMarkers, mapView: nil)

        self.markerAnimationController.clusteringAnimation(
            old: oldMarkers.map { $0.position },
            new: newMarkers.map { $0.position },
            isMerge: oldMarkers.count > newMarkers.count,
            completion: {
                self.setOveraysMapView(overlays: newMarkers, mapView: self.mapView)
                self.setMarkersBounds(markers: newMarkers, bounds: bounds)
                completion?()
            })
    }
}

extension MainViewController: NMFMapViewCameraDelegate {
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let boundsLatLngs = mapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])
        interactor?.fetchPOI(southWest: southWest, northEast: northEast)
    }
}

extension MainViewController: ClusteringTool {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        return projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
}
