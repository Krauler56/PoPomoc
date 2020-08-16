//
//  DashboardPresenter.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import RxSwift
import RxCocoa
import XCoordinator

final class DashboardPresenter: DashboardPresenterProtocol {

    // MARK: - Inputs

    let viewDidLoadTrigger = PublishRelay<Void>()
    let viewWillAppearTrigger = PublishRelay<Void>()
    let viewWillDisappearTrigger = PublishRelay<Void>()
    let moduleSelected = PublishRelay<DashboardViewModel>()
    
    // MARK: - Outputs
    var types: Driver<[DashboardViewModel]> {
        return Observable<[DashboardViewModel]>.just([DashboardViewModel(type: .trackHelp, title: "Autolaweta", image: R.image.towingVehicle()!),
                                                      DashboardViewModel(type: .assistance, title: "Pomoc drogowa", image: R.image.professionsAndJobs()!),
                                                      DashboardViewModel(type: .trackRent, title: "Wynajem lawety", image: R.image.towTruck()!)]).asDriver(onErrorJustReturn: [])
    }
    // MARK: - Attributes

    private let interactor: DashboardInteractorProtocol
    var coordinator: UnownedRouter<DashboardRoute>?
    
    private let disposeBag = DisposeBag()

    // MARK: - Functions

    init(interactor: DashboardInteractorProtocol) {
        self.interactor = interactor
        inputs.viewDidLoadTrigger.subscribe(onNext: { [weak self] in
            self?.viewDidLoad()
        }).disposed(by: disposeBag)
    }
}

private extension DashboardPresenter {
    
    func viewDidLoad() {
        moduleSelected.subscribe(onNext: { [unowned self] in
            self.processModuleTypeOnClick(module: $0.type)
            
            })
            .disposed(by: disposeBag)
    }
    
    func processModuleTypeOnClick(module: DashboardModuleType) {
        switch module {
        case .trackHelp:
            coordinator?.trigger(.map)
        case .assistance:
            coordinator?.trigger(.map)
        case .trackRent:
            coordinator?.trigger(.map)
        }
    }
}
