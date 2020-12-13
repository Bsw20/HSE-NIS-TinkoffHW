//
//  SceneDelegate.swift
//  Stocks
//
//  Created by Ярослав Карпунькин on 13.12.2020.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let vc = MainController()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        
    }

}

