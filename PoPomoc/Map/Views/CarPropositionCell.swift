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
    
    var labelContrainer = UIView()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.secondaryColorTurquoise
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.secondaryColorTurquoise
        return label
    }()
    
    var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.secondaryColorTurquoise
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
        setupSelectedBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        backgroundColor = Colors.specialGray
        addSubview(companyLogo)
        addSubview(labelContrainer)
        addSubview(priceLabel)
        labelContrainer.addSubview(nameLabel)
        labelContrainer.addSubview(timeLabel)
    }
    
    func setupConstraints() {
        
        companyLogo.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.equalTo(64)
            $0.height.equalTo(64)
        }
        
        labelContrainer.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.equalTo(companyLogo.snp.trailing).offset(30)
        }
        
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(labelContrainer.snp.trailing)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
        }
        nameLabel.snp.makeConstraints {
            $0.top.trailing.leading.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(5)
        }
    }
    
    func setupSelectedBackgroundColor() {
        let view = UIView()
        view.backgroundColor = Colors.specialOrange
        self.selectedBackgroundView = view
    }
}

struct Company {
    let title: String
    let image: UIImage
    let price: Decimal
    let waitingTime: Int
}
