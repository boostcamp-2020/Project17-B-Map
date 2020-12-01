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
        guard let pois = coreDataLayer.fetch() else {
            debugPrint("LoadViewController.viewDidAppear.load fail 알람창 만들기")
            return
        }
        
        self.fetchSuccess(count: pois.count)
    }

    private func fetchSuccess(count: Int) {
        guard count > 0 else {
            self.loadData { result in
                switch result {
                case .failure(let error):
                    debugPrint("\(error) 알람창 만들기")
                default:
                    self.presentMainViewController()
                }
            }
            return
        }
        self.presentMainViewController()
    }
    
    private func loadData(completion handler: @escaping (Result<Void, CoreDataError>) -> Void) {
        jsonParser.parse(fileName: "gangnam_8000") { [weak self] result in
            do {
                let places = try result.get()
                self?.coreDataLayer.add(places: places) { result in
                    handler(result)
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
