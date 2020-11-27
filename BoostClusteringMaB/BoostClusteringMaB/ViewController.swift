//
//  ViewController.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit
import NMapsMap

class ViewController: UIViewController {
    lazy var mapView = NMFNaverMapView(frame: view.frame)
    var naverMapView: NMFMapView!
    var markers = [NMFMarker]()
    var poiData: [POI]?
	var clustering: Clustering?
    var polygonOverlays = [NMFPolygonOverlay]()

    let coreDataLayer: CoreDataManager = CoreDataLayer()
    let animationOperationQueue = OperationQueue.main
    let markerImageView = MarkerImageView(radius: 30)

    var markerAnimationController: MarkerAnimateController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        try? coreDataLayer.removeAll()
//        jsonToData(name: "gangnam_8000")
//        jsonToData(name: "restaurant")
        configureMapView()
		configureClustering()

        markerAnimationController = MarkerAnimateController(view: view,
                                                                projection: naverMapView.projection)
        
    }
	
	private func configureClustering() {
		clustering = Clustering(naverMapView: naverMapView, coreDataLayer: coreDataLayer)
	}
    
    private func configureMapView() {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.50378338836959, lng: 127.05559154398587)) // 강남
        // let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: 37.56295485320913, lng: 126.99235958053829)) // 을지로
        naverMapView = mapView.mapView
        mapView.showZoomControls = true

        view.addSubview(mapView)
        naverMapView.touchDelegate = self
        naverMapView.addCameraDelegate(delegate: self)
        
        naverMapView.moveCamera(cameraUpdate)
    }
    
    func createMarker(latLng: LatLng) -> NMFMarker {
        let marker = NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
        return marker
    }
    
    private func jsonToData(name: String) {
        if let path = Bundle.main.url(forResource: name, withExtension: "json") {
            guard let data = try? Data(contentsOf: path) else { return  }
            let jsonResult = try? JSONDecoder().decode(Places.self, from: data)
            jsonResult?.places.forEach({
                try? coreDataLayer.add(place: $0) {
                    try? self.coreDataLayer.save()
                }
            })
        }
    }
    
    var newMarkers: [NMFMarker]?
}

extension ViewController: NMFMapViewCameraDelegate {
    enum ClusteringAnimationType {
        case merge, divide
    }
    
    private func createMarkers(latLngs: [LatLng], pointSizes: [Int]) -> [NMFMarker] {
        return zip(latLngs, pointSizes).map {
            let marker = self.createMarker(latLng: $0)
            if $1 != 1 {
                marker.setImageView(self.markerImageView, count: $1)
            }
            return marker
        }
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
		//움직인 좌표로 Fetch
		clustering?.findOptimalClustering(completion: { [weak self] array, pointSize, convexHullPoints in
            guard let self = self else { return }

            let newMarkers = self.createMarkers(latLngs: latLngs, pointSizes: pointSizes)
            
            guard self.markers.count != 0 else {
                newMarkers.forEach { $0.mapView = self.naverMapView }
                self.markers = newMarkers
                return
            }
            
            self.markers.forEach({
                $0.mapView = nil
            })
            self.markers = newMarkers

            self.markers.forEach({
                $0.mapView = self.naverMapView
            })

            // MARK: Animation

//            if self.markers.count > newMarkers.count {
//                self.markerClustringAnimation(.merge, newMarkers)
//            } else if self.markers.count < newMarkers.count {
//                self.markerClustringAnimation(.divide, newMarkers)
//            }
			
            self.polygonOverlays.forEach {
                $0.mapView = nil
            }
            
            self.polygonOverlays.removeAll()
            
			// MARK: - 영역표시
            for latlngs in convexHullPoints where latlngs.count > 3 {
				let points = latlngs.map { NMGLatLng(lat: $0.lat, lng: $0.lng) }

				guard let polygon = NMGPolygon(ring: NMGLineString(points: points)) as? NMGPolygon<AnyObject>,
                      let polygonOverlay = NMFPolygonOverlay(polygon) else { continue }
                
				polygonOverlay.fillColor = UIColor(red: 25.0/255.0, green: 192.0/255.0, blue: 46.0/255.0, alpha: 31.0/255.0)
				polygonOverlay.outlineWidth = 3
				polygonOverlay.outlineColor = UIColor(red: 25.0/255.0, green: 192.0/255.0, blue: 46.0/255.0, alpha: 1)
				polygonOverlay.mapView = self.naverMapView
                self.polygonOverlays.append(polygonOverlay)
			}
        })
    }

    private func markerClustringAnimation(_ type: ClusteringAnimationType, _ newMarkers: [NMFMarker]) {
        let upperMarkers = (type == .merge) ? newMarkers : markers
        let lowerMarkers = (type == .merge) ? markers : newMarkers
        
        switch type {
        case .merge:
            newMarkers.forEach { $0.mapView = naverMapView }
        case .divide:
            markers.forEach { $0.mapView = nil }
        }
        
        lowerMarkers.forEach { lowerMarker in
            var nearestMarker = upperMarkers[0]
            var minDistance = squaredDistance(lowerMarker, nearestMarker)

            
            self.markerAnimationController?.clusteringAnimation(
                old: self.markers.map { $0.position },
                new: newMarkers.map { $0.position },
                isMerge: self.markers.count > newMarkers.count) {
                // after animation
                self.markers = newMarkers
                
                self.markers.forEach({
                    $0.mapView = self.naverMapView
                })
            }
        })
    }
    
}

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // MARK: - 화면 터치시 마커 찍기
//        let marker = NMFMarker(position: latlng)
//        marker.mapView = mapView
    }
}

extension NMFMarker {
    func setImageView(_ view: MarkerImageView, count: Int) {
        view.text = "\(count)"
        iconImage = .init(image: view.snapshot())
    }
}
