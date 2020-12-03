//
//  MainInteractor.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/30.
//

import Foundation

protocol MainDataStore {
//    var coreData: POI { get set }
}

protocol MainBusinessLogic {
    func fetchPOI(southWest: LatLng, northEast: LatLng, zoomLevel: Double)
    func addLocation(_ latlng: LatLng, southWest: LatLng, northEast: LatLng, zoomLevel: Double)
    func deleteLocation(_ latlng: LatLng, southWest: LatLng, northEast: LatLng, zoomLevel: Double)
}

final class MainInteractor: MainDataStore {
    var presenter: MainPresentationLogic?
    
    let coreDataLayer: CoreDataManager = CoreDataLayer()
    var clustering: Clustering?
    
    init() {
        configureClustering()
    }
    
    private func configureClustering() {
        clustering = Clustering(coreDataLayer: coreDataLayer)
    }
    
}

extension MainInteractor: MainBusinessLogic {
    func fetchPOI(southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
        clustering?.findOptimalClustering(southWest: southWest, northEast: northEast, zoomLevel: zoomLevel)
    }
    
    func addLocation(_ latlng: LatLng, southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
        coreDataLayer.add(place: Place(id: "9999", name: "새로운 데이터",
                                       x: "\(latlng.lng)",
                                       y: "\(latlng.lat)",
                                       imageURL: nil,
                                       category: "new")) { _ in
            self.fetchPOI(southWest: southWest, northEast: northEast, zoomLevel: zoomLevel)
        }
    }
    
    func deleteLocation(_ latlng: LatLng, southWest: LatLng, northEast: LatLng, zoomLevel: Double) {
        coreDataLayer.remove(location: latlng) { _ in
            self.fetchPOI(southWest: southWest, northEast: northEast, zoomLevel: zoomLevel)
        }
    }
}
