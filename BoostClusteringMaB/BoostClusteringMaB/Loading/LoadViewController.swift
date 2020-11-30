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
        super.viewDidAppear(animated)
        
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
        jsonParser.parse(fileName: "gangnam_8000") { [weak self] result in
            do {
                let places = try result.get()
                try self?.coreDataLayer.add(places: places) {
                    try? self?.coreDataLayer.save()
                    handler()
                }
            } catch {
                print(error)
                // 예외처리
            }
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
