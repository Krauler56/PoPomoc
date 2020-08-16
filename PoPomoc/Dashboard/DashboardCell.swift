//
//  DashboardCell.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//  Copyright © 2020 Valentin. All rights reserved.
//

import Foundation
import UIKit

class DashboardCell: UICollectionViewCell {
	
	private let contrainerView: UIView = {
		let container = UIView()
		container.backgroundColor = Colors.secondaryColorTurquoise
		container.clipsToBounds = true
		container.layer.cornerRadius = 8
		return container
	}()
	
	private let titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = .white
		return label
	}()
	
	private let image: UIImageView = {
		let imageView = UIImageView()
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: .zero)
		setupView()
		setupConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func setupView() {
		addSubview(contrainerView)
		contrainerView.addSubview(image)
		contrainerView.addSubview(titleLabel)
	}
	
	func setupConstraints() {
		contrainerView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		image.snp.makeConstraints {
			$0.leading.equalToSuperview().offset(40)
			$0.centerY.equalToSuperview()
			$0.height.width.equalTo(60)
		}
		titleLabel.snp.makeConstraints {
			$0.top.bottom.equalToSuperview()
			$0.leading.equalTo(image.snp.trailing).offset(40)
			$0.trailing.equalToSuperview().offset(-40)
		}
	}
	func setupCell(viewModel: DashboardViewModel) {
		titleLabel.text = viewModel.title
		image.image = viewModel.image
	}
}
