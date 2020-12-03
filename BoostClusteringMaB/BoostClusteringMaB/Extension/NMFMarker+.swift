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

    /// 위치와 갯수를 입력하면 NMFMarker배열로 만들어줌
    /// - Parameters:
    ///   - latLngs: 클러스터 위치
    ///   - pointSizes: 클러스터 안에 POI 갯수
    /// - Returns: 입력된 값으로 만든 마커들
    static func markers(latLngs: [LatLng], pointSizes: [Int]) -> [NMFMarker] {
        return zip(latLngs, pointSizes).map { latLng, pointSize in
            let marker = NMFMarker(position: NMGLatLng(lat: latLng.lat, lng: latLng.lng))
            marker.captionText = "\(pointSize)"
            marker.captionTextSize = 0
            guard pointSize != 1 else { return marker }
            marker.setImageView(markerImageView, count: pointSize)
            return marker
        }
    }

    /// count를 입력하면 네이버 맵뷰에 마커 찍어줌
    /// - Parameters:
    ///   - view: MarkerImageView
    ///   - count: 클러스터 안에 POI 갯수
    func setImageView(_ view: MarkerImageView, count: Int) {
        view.text = "\(count)"
        iconImage = .init(image: view.snapshot())
    }
}
