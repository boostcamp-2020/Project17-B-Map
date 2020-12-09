//
//  NMFMarker+.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation
import NMapsMap

extension NMFMarker {
    static let maxSize: CGFloat = 80
    static let markerImageView = MarkerImageView(size: maxSize)
    
    /// 위치와 갯수를 입력하면 NMFMarker배열로 만들어줌
    /// - Parameters:
    ///   - latLngs: 클러스터 위치
    ///   - pointCount: 클러스터 안에 POI 갯수
    /// - Returns: 입력된 값으로 만든 마커들
    static func markers(latLngs: [LatLng], pointCount: [Int]) -> [NMFMarker] {
        guard let maxSize = pointCount.max() else { return [] }
        
        return zip(latLngs, pointCount).map { latLng, pointCount in
            let marker = NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
            marker.userInfo["pointCount"] = pointCount
            guard pointCount != 1 else {
                marker.iconImage = NMF_MARKER_IMAGE_BLACK
                marker.iconTintColor = UIColor.naverGreen
                return marker
            }
            marker.setImageView(
                markerImageView,
                count: pointCount,
                sizeRatio: CGFloat(pointCount) / CGFloat(maxSize))
            return marker
        }
    }
    
    /// count를 입력하면 네이버 맵뷰에 마커 찍어줌
    /// - Parameters:
    ///   - view: MarkerImageView
    ///   - count: 클러스터 안에 POI 갯수
    ///   - sizeRatio: 클러스터 크기 비율
    func setImageView(_ view: MarkerImageView, count: Int, sizeRatio: CGFloat) {
        view.text = "\(count)"
        view.size = NMFMarker.maxSize * (1 + sizeRatio) / 2
        iconImage = .init(image: view.snapshot())
    }
}
