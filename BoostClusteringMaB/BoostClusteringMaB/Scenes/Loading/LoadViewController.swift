//
//  LoadViewController.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/11/27.
//

import UIKit

class LoadViewController: UIViewController {
    @IBOutlet weak var leftMarker: UIImageView!
    @IBOutlet weak var rightMarker: UIImageView!
    
    private let coreDataLayer = CoreDataLayer()
    private let jsonParser = JsonParser()
    
    let defaultJSON = "restaurant"
    
    override func viewDidAppear(_ animated: Bool) {
        animate()
        guard let pois = coreDataLayer.fetch() else {
            debugPrint("LoadViewController.viewDidAppear.load fail 알람창 만들기")
            return
        }
        self.fetchSuccess(count: pois.count)
    }
    
    private func animate() {
        let distance = view.frame.height * 0.08
        addAnimation(distance: distance, to: leftMarker)
        addAnimation(distance: distance * 0.6, to: rightMarker)
    }
    
    func addAnimation(distance: CGFloat, to view: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.45
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.fromValue = view.center
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.toValue = CGPoint(x: view.center.x, y: view.center.y - distance)
        view.layer.add(animation, forKey: "position")
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
        jsonParser.parse(fileName: defaultJSON) { [weak self] result in
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
