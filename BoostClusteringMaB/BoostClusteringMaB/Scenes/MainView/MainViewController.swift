//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap
import CoreData

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
        naverMapView.addSubview(animationView)
        return controller
    }()
    //lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남
    lazy var startPoint = NMGLatLng(lat: 37.56295485320913, lng: 126.99235958053829) // 을지로

    var displayedData: ViewModel = .init(markers: [], polygons: [], bounds: [], count: 0)
    var interactor: MainBusinessLogic?
    var mapView: NMFMapView { naverMapView.mapView }
    var projection: NMFProjection { naverMapView.mapView.projection }
    
    private lazy var bottomSheetViewController: DetailViewController = {
        guard let bottom = storyboard?.instantiateViewController(withIdentifier: "DetailViewController")
                as? DetailViewController else { return DetailViewController() }
        return bottom
    }()
    
    var boundsLatLng: (southWest: LatLng, northEast: LatLng) {
        let boundsLatLngs = mapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])
        
        return (southWest: southWest, northEast: northEast)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVIP()
        configureMapView()
        configureBottomSheetView()
    }
    
    func configureBottomSheetView() {
        addChild(bottomSheetViewController)
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        let height = view.frame.height
        let width = view.frame.width
        let maxY = view.frame.maxY
        bottomSheetViewController.view.frame = CGRect(x: 0, y: maxY, width: width, height: height)
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
        
        var nowZoomLevel = mapView.zoomLevel
        let stdZoomLevel = NMF_MAX_ZOOM - 2
        if  nowZoomLevel < stdZoomLevel {
            nowZoomLevel = stdZoomLevel
        }
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: latlng, zoomTo: nowZoomLevel)
        cameraUpdate.animation = .easeIn
        cameraUpdate.animationDuration = 0.8
        sender.state = .ended
        
        self.showAlert(latlng: latlng, type: .append) {
            self.interactor?.addLocation(LatLng(latlng),
                                         southWest: self.boundsLatLng.southWest,
                                         northEast: self.boundsLatLng.northEast,
                                         zoomLevel: self.mapView.zoomLevel)
            self.mapView.moveCamera(cameraUpdate)
        }
    }
    
    private func showAlert(latlng: NMGLatLng, type: AlertType, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: type.title,
                                      message: type.message,
                                      preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
            handler()
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
        //collectionView.reloadData()
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
            marker.touchHandler = { [weak self] _ in
                guard let self = self else {
                    return true
                }
                
                if marker.captionText == "1" {
                    self.showAlert(latlng: marker.position, type: .delete) {
                        marker.mapView = nil
                        self.interactor?.deleteLocation(LatLng(marker.position),
                                                        southWest: self.boundsLatLng.southWest,
                                                        northEast: self.boundsLatLng.northEast,
                                                        zoomLevel: self.mapView.zoomLevel)
                    }
                } else {
                    self.touchedMarker(bounds: bound, insets: 5)
                }
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
        let zoomLevel = mapView.zoomLevel
        interactor?.fetchPOI(southWest: boundsLatLng.southWest, northEast: boundsLatLng.northEast, zoomLevel: zoomLevel)
    }
}

extension MainViewController: ClusteringTool {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        return projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
}
