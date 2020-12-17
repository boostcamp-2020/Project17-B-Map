//
//  UIColor+.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/02.
//

import UIKit
extension UIColor {
    /// UIColor 랜덤으로 생성
    ///
    /// - 기존에 있던 UIColor(red:, green:, blue:, alpha:) init 메소드에서 r, g, b에만 random 메소드로 값을 지정
    /// - alpha는 31.0/255.0로 고정
    ///
    /// - Returns: Random UIColor
    static func random() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0.0...1.0),
                       green: CGFloat.random(in: 0.0...1.0),
                       blue: CGFloat.random(in: 0.0...1.0),
                       alpha: 31.0/255.0)
    }

    /// Naver Color
    static let naverGreen = UIColor(named: "NaverColor") ?? UIColor.systemGreen
}
