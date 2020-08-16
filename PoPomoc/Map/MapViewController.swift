//
//  MapViewController.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MapViewController: BaseViewController {
	
	// MARK: - Attributes
	var presenter: MapPresenterProtocol!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Views
}

// MARK: - View Lifecycle
extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureComponents()
        presenter.inputs.viewDidLoadTrigger.accept(())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.inputs.viewWillAppearTrigger.accept(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.inputs.viewWillDisappearTrigger.accept(())
    }
}

// MARK: - Private functions
private extension MapViewController {
    
    func configureComponents() {
        addSubviews()
        addConstraints()
        setupRx()
    }
    
    func addSubviews() {
    }
    
    func addConstraints() {
    }
    
    func setupRx() {
    }
}
