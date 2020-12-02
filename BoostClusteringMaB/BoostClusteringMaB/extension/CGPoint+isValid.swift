//
//  CGPoint+isValid.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//

import UIKit

extension CGPoint {
    /// Maps API의 projection.point가 유효하지 않은 좌표에서 CGPoint.x가 무한대이거나 CGPoint.y가 무한대인 좌표를 반환
    var isValid: Bool {
        return distance(to: .zero) < 1000
    }
}
