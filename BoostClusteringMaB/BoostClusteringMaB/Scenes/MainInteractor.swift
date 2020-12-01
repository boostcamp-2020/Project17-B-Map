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
    func fetchPOI(clustering: Clustering?)
}

final class MainInteractor: MainDataStore {
    var presenter: MainPresentationLogic?
}

extension MainInteractor: MainBusinessLogic {

    func fetchPOI(clustering: Clustering?) {
    }
}
