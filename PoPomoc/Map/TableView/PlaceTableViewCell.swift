//
//  PlaceTableViewCell.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import Foundation
import UIKit

class PlaceTableViewCell: UITableViewCell {
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = Colors.secondaryColorTurquoise
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        backgroundColor = Colors.mainColorBeige
        addSubview(label)
    }
    
    func setupConstraints() {
        label.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
        }
    }
}

extension UITableViewCell {
    static let reuseIdentifier = String(describing: self)
}
