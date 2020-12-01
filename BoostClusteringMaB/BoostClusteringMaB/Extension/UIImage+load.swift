//
//  UIImage+load.swift
//  BoostClusteringMaB
//
//  Created by 조정래 on 2020/12/01.
//

import UIKit

extension UIImage {
    
    static func load(imageURL: String) -> UIImage? {
        guard let url = URL(string: imageURL), let data = try? Data(contentsOf: url) else { return UIImage()}
        return UIImage(data: data)
    }
    
}
