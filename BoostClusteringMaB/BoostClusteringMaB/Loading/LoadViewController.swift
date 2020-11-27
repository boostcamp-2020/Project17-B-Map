//
//  LoadViewController.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//

import UIKit

class LoadViewController: UIViewController {
    private let coreDataLayer = CoreDataLayer()
    private let jsonParser = JsonParser()
    
    override func viewDidAppear(_ animated: Bool) {
        guard let count = try? coreDataLayer.fetch().count,
              count > 0 else {
            loadData {
                self.presentMainViewController()
            }
            return
        }
        
        presentMainViewController()
    }
    
    private func loadData(completion handler: @escaping () -> Void) {
        jsonParser.jsonToData(name: "gangnam_8000") {
            handler()
        }
    }
    
    func presentMainViewController() {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() else {
            return
        }
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        
        present(viewController, animated: true, completion: nil)
    }
}
