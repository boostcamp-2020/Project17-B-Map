//
//  CGPoint+Distance.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/11/23.
//

import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> Double {
        return Double(sqrt(pow((point.x - x), 2) + pow((point.y - y), 2)))
    }
}
