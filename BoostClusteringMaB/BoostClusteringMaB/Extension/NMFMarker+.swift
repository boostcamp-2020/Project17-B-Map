//
//  NMFMarker+.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation
import NMapsMap

extension NMFMarker {
    static let markerImageView = MarkerImageView(radius: 30)
    
    static func markers(latLngs: [LatLng], pointSizes: [Int]) -> [NMFMarker] {
        return zip(latLngs, pointSizes).map { latLng, pointSize in
            let marker = NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
            guard pointSize != 1 else { return marker }
            marker.setImageView(markerImageView, count: pointSize)
            return marker
        }
    }
    
    func setImageView(_ view: MarkerImageView, count: Int) {
        view.text = "\(count)"
        iconImage = .init(image: view.snapshot())
    }
}
