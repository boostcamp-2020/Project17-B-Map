//
//  NMFCameraUpdate+.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/12/11.
//

import NMapsMap

extension NMFCameraUpdate {
    convenience init(fit: NMGLatLngBounds,
                     paddingInsets: UIEdgeInsets,
                     cameraAnimation: NMFCameraUpdateAnimation,
                     duration: Double) {
        self.init(fit: fit, paddingInsets: paddingInsets)
        animation = cameraAnimation
        animationDuration = duration
    }

    convenience init(scrollTo: NMGLatLng,
                     zoomTo: Double,
                     cameraAnimation: NMFCameraUpdateAnimation,
                     duration: Double) {
        self.init(scrollTo: scrollTo, zoomTo: zoomTo)
        animation = cameraAnimation
        animationDuration = duration
    }
}
