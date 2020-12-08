//
//  ClusteringProtocol.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/02.
//

import UIKit

protocol ClusteringTool: class {
    func convertLatLngToPoint(latLng: LatLng) -> CGPoint
}

protocol ClusteringData: class {
    func redrawMap(_ latLngs: [LatLng],
                   _ pointCount: [Int],
                   _ bounds: [(southWest: LatLng, northEast: LatLng)],
                   _ convexHulls: [[LatLng]])
}
