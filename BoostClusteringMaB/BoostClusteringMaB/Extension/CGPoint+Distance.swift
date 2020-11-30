//
//  CGPoint+Distance.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import UIKit
import NMapsMap

extension CGPoint {
    func distance(to point: CGPoint) -> Double {
        return Double(sqrt(pow((point.x - x), 2) + pow((point.y - y), 2)))
    }
    
    func convert(mapView: NMFMapView) -> NMGLatLng {
        let projection = mapView.projection
        let coord = projection.latlng(from: self)
        return coord
    }
}
