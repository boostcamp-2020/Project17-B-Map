//
//  UIColor+RandomColor.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/12/01.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat.random(in: 0.0...1.0),
                       green: CGFloat.random(in: 0.0...1.0),
                       blue: CGFloat.random(in: 0.0...1.0),
                       alpha: 31.0/255.0)
    }
}
