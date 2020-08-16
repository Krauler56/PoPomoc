//
//  DashboardViewController.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class DashboardViewController: UIViewController {
    
    // MARK: - Attributes
    var presenter: DashboardPresenterProtocol!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Views
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 50
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(DashboardCell.self)
        collection.backgroundColor = Colors.mainColorBeige
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
}

// MARK: - View Lifecycle
extension DashboardViewController {
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
private extension DashboardViewController {
    
    func configureComponents() {
        addSubviews()
        addConstraints()
        setupRx()
    }
    
    func addSubviews() {
        view.addSubview(collectionView)
    }
    
    func addConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.bottom.trailing.leading.equalToSuperview()
        }
    }
    
    func setupRx() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        presenter.outputs
            .types
            .drive(collectionView.rx.items(cellIdentifier: DashboardCell.reuseIdentifier, cellType: DashboardCell.self)) { index, model, cell in
                cell.setupCell(viewModel: model)
            }.disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(DashboardViewModel.self)
            .bind(to: presenter.inputs.moduleSelected)
            .disposed(by: disposeBag)
        
    }
}

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.collectionView.frame.size.width-40;
        
        
        return CGSize(width: width, height: 100)
        
    }
}
