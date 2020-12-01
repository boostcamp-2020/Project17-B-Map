//
//  MainPresenter.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/30.
//

import Foundation

protocol MainPresentationLogic {
    func presentFetchedPOI()
}

final class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?

    func presentFetchedPOI() {
        viewController?.displayFetchedCoreData(viewModel: [POI]())
    }
}
