//
//  DashboardCoordinator.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import Foundation
import XCoordinator

enum DashboardRoute: Route {
    case home
    case map
}

class DashboardCoordinator: NavigationCoordinator<DashboardRoute> {
  
    private let resolver = DependencyProvider.shared.resolver
  
    init() {
        super.init(initialRoute: .home)
      rootViewController.setNavigationBarHidden(true, animated: false)
    }

    override func prepareTransition(for route: DashboardRoute) -> NavigationTransition {
        switch route {
        case .home:
          let test = resolver.resolve(DashboardViewController.self, argument: self.unownedRouter)!
          return .show(test)
        case .map:
          let test = resolver.resolve(MapViewController.self)!
          return .show(test)
        }
    }
}
