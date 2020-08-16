//
//  DesktopCell.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//  Copyright © 2020 Valentin. All rights reserved.
//

import Foundation
import UIKit

class DesktopCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func setupView() {
        backgroundColor = .red
    }
}
