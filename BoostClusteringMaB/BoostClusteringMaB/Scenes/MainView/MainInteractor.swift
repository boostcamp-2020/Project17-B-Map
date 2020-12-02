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
    func fetchPOI(southWest: LatLng, northEast: LatLng)
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

    func fetchPOI(southWest: LatLng, northEast: LatLng) {
        clustering?.findOptimalClustering(southWest: southWest, northEast: northEast)
    }
}
