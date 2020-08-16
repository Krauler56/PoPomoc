//
//  MapPresenter.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import RxSwift
import RxCocoa

final class MapPresenter: MapPresenterProtocol {

    // MARK: - Inputs

    let viewDidLoadTrigger = PublishRelay<Void>()
    let viewWillAppearTrigger = PublishRelay<Void>()
    let viewWillDisappearTrigger = PublishRelay<Void>()

    // MARK: - Outputs

    // MARK: - Attributes

    private let interactor: MapInteractorProtocol
    weak var coordinator: MapCoordinatorDelegate?

    private let disposeBag = DisposeBag()

    // MARK: - Functions

    init(interactor: MapInteractorProtocol) {
        self.interactor = interactor
        inputs.viewDidLoadTrigger.subscribe(onNext: { [weak self] in
            self?.viewDidLoad()
        }).disposed(by: disposeBag)
    }
}

private extension MapPresenter {
    
    func viewDidLoad() {
        // setup rx binding make first WS calls etc.
    }
}
