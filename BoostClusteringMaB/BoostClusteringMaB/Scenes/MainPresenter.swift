//
//  MainPresenter.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/30.
//

import Foundation

protocol MainPresentationLogic {
    func presentFetchedCoreData()
}

final class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?

    func presentFetchedCoreData() {
        viewController?.displayFetchedCoreData(viewModel: [POI]())
    }
}
