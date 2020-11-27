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
        findOptimalClustering(completion: { [weak self] latLngs, pointSizes in
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
        })
    }
}
