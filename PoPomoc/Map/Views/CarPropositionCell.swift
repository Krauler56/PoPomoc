//
//  CarPropositionCell.swift
//  PoPomoc
//
//  Created by Valentin on 23/08/2020.
//

import Foundation
import UIKit

class CarPropositionCell: UITableViewCell {
    
    var companyLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.towingVehicle()
        return imageView
    }()
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
        backgroundColor = Colors.specialGray
        addSubview(companyLogo)
        addSubview(label)
    }
    
    func setupConstraints() {
        
        companyLogo.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(40)
        }
        
        label.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(companyLogo.snp.trailing).offset(30)
            
        }
    }
}

struct Company {
    let title: String
    let image: UIImage
}
