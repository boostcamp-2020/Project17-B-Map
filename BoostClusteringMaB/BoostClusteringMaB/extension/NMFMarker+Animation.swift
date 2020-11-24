//
//  NMFMarker+Animation.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/24.
//

import Foundation
import NMapsMap

// MARK: Marker Animation
extension NMFMarker {
    func moveWithAnimation(_ mapView: NMFMapView, to destination: NMGLatLng, complete: (() -> Void)?) {
        let div = 500
        let latLen = (destination.lat - position.lat) / Double(div)
        let lngLen = (destination.lng - position.lng) / Double(div)
        
        DispatchQueue.global().async {
            for divCount in 0...div {
                OperationQueue.main.addOperation {
                    self.position = .init(lat: self.position.lat + latLen, lng: self.position.lng + lngLen)
                    if divCount == div {
                        self.position = destination
                        complete?()
                    }
                }
            }
        }
    }
}
