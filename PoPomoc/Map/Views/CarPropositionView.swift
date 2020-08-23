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
    view.backgroundColor = Colors.mainColorBeige
  }
  private func setupView() {
    view.addSubview(handleArea)
    view.addSubview(tableView)
  }
  
  private func setupConstraints() {
    handleArea.backgroundColor = .blue
    handleArea.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(50)
    }
    
    tableView.snp.makeConstraints {
        $0.top.equalTo(handleArea.snp.bottom)
        $0.leading.trailing.bottom.equalToSuperview()
    }
  }
}
