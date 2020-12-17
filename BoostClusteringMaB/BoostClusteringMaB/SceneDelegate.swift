//
//  SceneDelegate.swift
//  BoostClusteringMaB
//
//  Created by ParkJaeHyun on 2020/11/16.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataContainer.shared.saveContext()
    }
}
