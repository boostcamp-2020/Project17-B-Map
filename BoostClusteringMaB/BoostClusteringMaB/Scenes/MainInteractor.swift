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
    func fetchCoreData()
}

final class MainInteractor: MainDataStore {
    var presenter: MainPresentationLogic?
}

extension MainInteractor: MainBusinessLogic {
    func fetchCoreData() {
        presenter?.presentFetchedCoreData()
    }
}
