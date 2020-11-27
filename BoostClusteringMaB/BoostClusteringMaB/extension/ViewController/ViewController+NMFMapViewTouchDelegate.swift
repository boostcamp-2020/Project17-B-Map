//
//  ViewController+NMFMapViewTouchDelegate.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation
import NMapsMap

extension ViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        // MARK: - 화면 터치시 마커 찍기
        //        let marker = NMFMarker(position: latlng)
        //        marker.mapView = mapView
    }
}
