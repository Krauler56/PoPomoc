//
//  CarPropositionView.swift
//  PoPomoc
//
//  Created by Valentin on 21/08/2020.
//

import Foundation
import UIKit

class CarPropositionView: UIViewController {
    
    let handleArea = UIView()
    
    let handleRectangle: UIView = {
        let rectangle = UIView()
        rectangle.backgroundColor = .gray
        rectangle.layer.cornerRadius = 4
        return rectangle
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.rowHeight = 100
        table.tableFooterView = UIView(frame: .zero)
        table.register(CarPropositionCell.self, forCellReuseIdentifier: CarPropositionCell.reuseIdentifier)
        return table
    }()
    private let mainContainer = UIView()
    private let chooseButton = ChooseButton()
    
    override func viewDidLoad() {
        setupView()
        setupConstraints()
        view.backgroundColor = .clear
        handleArea.backgroundColor = Colors.specialGray
        mainContainer.backgroundColor = Colors.specialGray
        // view.backgroundColor = Colors.specialGray
    }
    private func setupView() {
        view.addSubview(chooseButton)
        view.addSubview(mainContainer)
        handleArea.addSubview(handleRectangle)
        mainContainer.addSubview(handleArea)
        mainContainer.addSubview(tableView)
    }
    
    private func setupConstraints() {
        chooseButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(64)
        }
        
        mainContainer.snp.makeConstraints {
            $0.top.equalTo(chooseButton.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        handleArea.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        handleRectangle.snp.makeConstraints {
            $0.height.equalTo(8)
            $0.width.equalTo(60)
            $0.centerY.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(handleArea.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
    }
}
