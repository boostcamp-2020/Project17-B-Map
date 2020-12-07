//
//  MainPresenter.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/30.
//

import Foundation
import NMapsMap

protocol MainPresentationLogic {
}

final class MainPresenter: MainPresentationLogic, ClusteringData {
    weak var viewController: MainDisplayLogic?
    
    func redrawMap(_ latLngs: [LatLng],
                   _ pointSizes: [Int],
                   _ bounds: [(southWest: LatLng, northEast: LatLng)],
                   _ convexHulls: [[LatLng]]) {

        let newMarkers = NMFMarker.markers(latLngs: latLngs, pointSizes: pointSizes)
        
        let newBounds = bounds.map {
            NMGLatLngBounds(southWest: NMGLatLng(lat: $0.lat, lng: $0.lng),
                            northEast: NMGLatLng(lat: $1.lat, lng: $1.lng))
        }

        let count = pointSizes.reduce(0) { $0 + $1 }

        let newPolygons = NMFPolygonOverlay.polygonOverlays(convexHulls: convexHulls)
        let newViewModel = ViewModel(markers: newMarkers, polygons: newPolygons, bounds: newBounds, count: count)
        
        viewController?.displayFetch(viewModel: newViewModel)
    }
}

struct ViewModel {
    let markers: [NMFMarker]
    let polygons: [NMFPolygonOverlay]
    let bounds: [NMGLatLngBounds]
    let count: Int
}
