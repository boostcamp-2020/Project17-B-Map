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
    func moveWithAnimation(_ mapView: NMFMapView, to destination: NMGLatLng, queue animationOperationQueue: OperationQueue, complete: (() -> Void)?) {
        
        let div = 500
        let latLen = (destination.lat - position.lat) / Double(div)
        let lngLen = (destination.lng - position.lng) / Double(div)
        animationOperationQueue.cancelAllOperations()
        animationOperationQueue.addOperation {
            for divCount in 0...div {
                DispatchQueue.main.async {
                    self.position = .init(lat: self.position.lat + latLen,
                                          lng: self.position.lng + lngLen)
                    if divCount == div {
                        self.position = destination
                        complete?()
                    }
                }
            }
        }
    }
}
