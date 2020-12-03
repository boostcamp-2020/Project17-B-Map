//
//  CGPoint+Distance.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import UIKit
import NMapsMap

extension CGPoint {
    
    /// 두개의 좌표간 거리 구하는 함수
    /// - Parameter point: 좌표
    /// 유클리디안 거리(Euclidean Distance)
    /// ```
    /// let point1 = CGPoint(x:1, y: 2)
    /// let point2 = CGPoint(x:2, y: 2)
    ///
    /// let distance = point1.distance(to: point2) // 1
    /// ```
    /// - Returns: 거리
    func distance(to point: CGPoint) -> Double {
        return Double(sqrt(pow((point.x - x), 2) + pow((point.y - y), 2)))
    }
    
    /// 화면좌표를 위도, 경도로 바꾸는 함수
    /// - Parameter mapView: NMapsMap
    /// - Returns: 위도, 경도를 반환(NMGLatLng)
    func convert(mapView: NMFMapView) -> NMGLatLng {
        let projection = mapView.projection
        let coord = projection.latlng(from: self)
        return coord
    }
}
