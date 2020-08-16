//
//  SceneDelegate.swift
//  PoPomoc
//
//  Created by Valentin on 10/08/2020.
//  Copyright © 2020 Valentin. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  let router = DashboardCoordinator().strongRouter

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
      if let windowScene = scene as? UIWindowScene {
          self.window = UIWindow(windowScene: windowScene)
          if let window = self.window {
              router.setRoot(for: window)
          }
      }
  }
}

