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
    private lazy var naverMapView = NMFNaverMapView(frame: view.frame)
    private lazy var markerAnimationController: MarkerAnimateController = {
        let controller = MarkerAnimateController(frame: view.frame, markerRadius: 30, mapView: mapView)
        guard let animationView = controller.view else { return controller }
        naverMapView.addSubview(animationView)
        return controller
    }()
    private lazy var bottomSheetViewController: DetailViewController = {
        guard let bottom = UIStoryboard(name: "Detail", bundle: nil).instantiateInitialViewController()
                as? DetailViewController else { return DetailViewController() }
        return bottom
    }()
    
    // private lazy var startPoint = NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587) // 강남
    private lazy var startPoint = NMGLatLng(lat: 37.56295485320913, lng: 126.99235958053829) // 을지로
    
    private var displayedData: ViewModel = .init(markers: [], polygons: [], bounds: [], count: 0)
    private var interactor: MainBusinessLogic?
    private var mapView: NMFMapView { naverMapView.mapView }
    private var projection: NMFProjection { naverMapView.mapView.projection }

    private var dotView: UIView?
    private var prevDotView: UIView?
    
    private var highlightMarker: NMFMarker? {
        willSet {
            newValue?.iconTintColor = UIColor.magenta
        }
        
        didSet {
            oldValue?.iconTintColor = UIColor.clear
        }
    }
    
    private var boundsLatLng: (southWest: LatLng, northEast: LatLng) {
        let boundsLatLngs = mapView.coveringBounds.boundsLatLngs
        let southWest = LatLng(boundsLatLngs[0])
        let northEast = LatLng(boundsLatLngs[1])
        
        return (southWest: southWest, northEast: northEast)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomSheetViewController.delegate = self
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
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            handler()
        })
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
}

extension MainViewController: MainDisplayLogic {
    func displayFetch(viewModel: ViewModel) {
        displayedData.markers.forEach({
            $0.touchHandler = nil
        })
        let oldViewModel = displayedData
        displayedData = viewModel
        redrawMap(oldViewModel: oldViewModel, newViewModel: viewModel)
    }
    
    private func redrawMap(oldViewModel: ViewModel?, newViewModel: ViewModel) {
        guard let oldViewModel = oldViewModel else {
            self.configureFirstMarkers(newMarkers: newViewModel.markers, bounds: newViewModel.bounds)
            return
        }

        self.setOverlaysMapView(overlays: oldViewModel.polygons, mapView: nil)
        
        self.markerChangeAnimation(
            oldMarkers: oldViewModel.markers,
            newMarkers: newViewModel.markers,
            bounds: newViewModel.bounds,
            completion: {
                self.setOverlaysMapView(overlays: newViewModel.polygons, mapView: self.mapView)
            })
    }
}

private extension MainViewController {
    func configureFirstMarkers(newMarkers: [NMFMarker], bounds: [NMGLatLngBounds]) {
        self.setOverlaysMapView(overlays: newMarkers, mapView: mapView)
        self.setMarkersBounds(markers: newMarkers, bounds: bounds)
    }
    
    func setOverlaysMapView(overlays: [NMFOverlay], mapView: NMFMapView?) {
        return overlays.forEach { $0.mapView = mapView }
    }
    
    func setMarkersBounds(markers: [NMFMarker], bounds: [NMGLatLngBounds]) {
        zip(markers, bounds).forEach { marker, bound in
            marker.touchHandler = { [weak self] _ in
                guard let self = self else { return true }
                guard let pointCount = marker.userInfo["pointCount"] as? Int else { return true }
                guard pointCount == 1 else {
                    self.touchedMarker(bounds: bound, insets: 5)
                    return true
                }
                
                guard marker == self.highlightMarker else {
                    self.highlightMarker = marker
                    return true
                }
                
                self.showAlert(latlng: marker.position, type: .delete) {
                    marker.mapView = nil
                    self.interactor?.deleteLocation(LatLng(marker.position),
                                                    southWest: self.boundsLatLng.southWest,
                                                    northEast: self.boundsLatLng.northEast,
                                                    zoomLevel: self.mapView.zoomLevel)
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
        self.setOverlaysMapView(overlays: oldMarkers, mapView: nil)

        self.markerAnimationController.clusteringAnimation(
            old: oldMarkers.map {
                (latLng: $0.position, radius: $0.iconImage.imageWidth / 2)
            },
            new: newMarkers.map {
                (latLng: $0.position, radius: $0.iconImage.imageWidth / 2)
            },
            isMerge: oldMarkers.count > newMarkers.count,
            completion: {
                self.setOverlaysMapView(overlays: newMarkers, mapView: self.mapView)
                self.setMarkersBounds(markers: newMarkers, bounds: bounds)
                completion?()
            })
    }
}

extension MainViewController: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        prevDotView?.layer.removeAllAnimations()
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let zoomLevel = mapView.zoomLevel
        highlightMarker = nil
        interactor?.fetchPOI(southWest: boundsLatLng.southWest, northEast: boundsLatLng.northEast, zoomLevel: zoomLevel)
        guard bottomSheetViewController.collectionView != nil else { return }
        bottomSheetViewController.reloadPOI(southWest: boundsLatLng.southWest, northEast: boundsLatLng.northEast)
    }
}

extension MainViewController: ClusteringTool {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint {
        return projection.point(from: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
    }
}

extension MainViewController: DetailViewControllerDelegate {
    func didCellSelected(lat: Double, lng: Double, isClicked: Bool) {
        prevDotView?.layer.removeAllAnimations()
        if isClicked {
            let cameraUpdate = NMFCameraUpdate(scrollTo: .init(lat: lat, lng: lng), zoomTo: 20)
            cameraUpdate.animation = .easeIn
            cameraUpdate.animationDuration = 0.8
            mapView.moveCamera(cameraUpdate)
        } else {
            let point = convertLatLngToPoint(latLng: LatLng(lat: lat, lng: lng))
            dotAnimation(point: point)
        }
    }

    func dotAnimation(point: CGPoint) {
        dotView = UIView(frame: .init(x: point.x, y: point.y, width: 4, height: 4))
        dotView?.layer.cornerRadius = 2
        dotView?.backgroundColor = .red
        self.naverMapView.addSubview(dotView ?? UIView())
        UIView.animate(withDuration: 0.3, delay: 0, options: .repeat) {
            self.dotView?.alpha = 0
        }
        prevDotView = dotView
    }
}

extension MainViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        highlightMarker = nil
    }
}
