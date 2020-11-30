//
//  NMFMarker+ImageView.swift
//  BoostClusteringMaB
//
//  Created by 김석호 on 2020/11/27.
//

import Foundation
import NMapsMap

extension NMFMarker {
    func setImageView(_ view: MarkerImageView, count: Int) {
        view.text = "\(count)"
        iconImage = .init(image: view.snapshot())
    }
}
