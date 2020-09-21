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
        table.rowHeight = 50
        table.tableFooterView = UIView(frame: .zero)
        table.register(CarPropositionCell.self, forCellReuseIdentifier: CarPropositionCell.reuseIdentifier)
        return table
    }()
    
    override func viewDidLoad() {
        setupView()
        setupConstraints()
        view.backgroundColor = Colors.specialGray
    }
    private func setupView() {
        view.addSubview(handleArea)
        handleArea.addSubview(handleRectangle)
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        handleArea.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
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
