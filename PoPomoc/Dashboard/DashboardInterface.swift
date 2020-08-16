//
//  DashboardInterface.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import RxSwift
import RxCocoa

protocol DashboardInteractorProtocol: AnyObject {
}

protocol DashboardCoordinatorDelegate: AnyObject {
}

protocol DashboardPresenterInputsProtocol: AnyObject {
    var viewDidLoadTrigger: PublishRelay<Void> { get }
    var viewWillAppearTrigger: PublishRelay<Void> { get }
    var viewWillDisappearTrigger: PublishRelay<Void> { get }
    var moduleSelected: PublishRelay<DashboardViewModel> { get }
}

protocol DashboardPresenterOutputsProtocol: AnyObject {
  var types: Driver<[DashboardViewModel]> { get }
}

protocol DashboardPresenterProtocol: DashboardPresenterInputsProtocol, DashboardPresenterOutputsProtocol {
    var inputs: DashboardPresenterInputsProtocol { get }
    var outputs: DashboardPresenterOutputsProtocol { get }
}

extension DashboardPresenterProtocol where Self: DashboardPresenterInputsProtocol & DashboardPresenterOutputsProtocol {
    var inputs: DashboardPresenterInputsProtocol { return self }
    var outputs: DashboardPresenterOutputsProtocol { return self }
}
