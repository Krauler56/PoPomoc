//
//  MainAssembly.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import Foundation
import Swinject
import XCoordinator

class DesktopAssembly: Assembly {
    
    func assemble(container: Swinject.Container) {
        
        container.register(DashboardViewController.self) { (resolver, router: UnownedRouter<DashboardRoute>) in
            let vc = DashboardViewController()
            let interactor = DashboardInteractor()
            let presenter = DashboardPresenter(interactor: interactor)
            presenter.coordinator = router
            vc.presenter = presenter
            return vc
        }
        
        container.register(MapViewController.self) { resolver in
            let vc = MapViewController()
            let interactor = MapInteractor()
            let presenter = MapPresenter(interactor: interactor)
            vc.presenter = presenter
            return vc
            
        }
    }
}


class DependencyProvider {
    
    static let shared = DependencyProvider()
    
    var resolver: Resolver {
        return assembler.resolver
    }
    
    private let topContainer = Container()
    
    private lazy var assembler = Assembler(assemblies, container: topContainer)
    
    private lazy var assemblies: [Assembly] = {
        return mainAssemblies // + ...
    }()
    
    private lazy var mainAssemblies: [Assembly] = [DesktopAssembly()]
    
    private init(){}
}
