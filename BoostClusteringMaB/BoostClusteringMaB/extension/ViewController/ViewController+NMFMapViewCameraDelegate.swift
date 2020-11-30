//
//  ViewController+NMFMapViewCameraDelegate.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation
import NMapsMap

extension ViewController: NMFMapViewCameraDelegate {
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

                guard let polygon = NMGPolygon(ring: NMGLineString(points: points)) as? NMGPolygon<AnyObject> else { return }
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
