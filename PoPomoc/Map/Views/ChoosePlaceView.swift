//
//  ChoosePlaceView.swift
//  PoPomoc
//
//  Created by Valentin on 18/08/2020.
//

import Foundation
import UIKit
import AnimatedField
import SnapKit
import RxSwift
import RxCocoa

class ChoosePlaceView: UIView {
    
    var destinationPlacemarkRxText: ControlProperty<String?>
    
    
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "Wprowadz adres docelowy"
        label.textColor = Colors.secondaryColorTurquoise
        return label
    }()
    
    private let textFieldStackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 250, height: 130))
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    
    private let placeMarkStackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 50, height: 130))
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 30
        return stackView
    }()
    
    private let firstPlaceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter text here"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.layer.cornerRadius = 8
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.backgroundColor = Colors.specialGray
        return textField
    }()
    
    private let secondPlaceTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter text here"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.layer.cornerRadius = 8
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        textField.backgroundColor = Colors.specialGray
        return textField
    }()
    
    private let firstPlaceMarkImage: UIImageView = {
       let firstImage = UIImageView()
        firstImage.image = R.image.place()?.maskWithColor(color: .red)
        return firstImage
    }()
    
    private let secondPlaceMarkImage: UIImageView = {
       let secondImage = UIImageView()
        secondImage.image = R.image.markedPlace()?.maskWithColor(color: Colors.secondaryColorTurquoise)
        return secondImage
    }()
    
    override init(frame: CGRect) {
        destinationPlacemarkRxText = secondPlaceTextField.rx.text
        super.init(frame: frame)
        setupView()
        setupConstraints()
        backgroundColor = Colors.cellTurquoise
    }
    
    required init?(coder aDecoder: NSCoder) {
        destinationPlacemarkRxText = firstPlaceTextField.rx.text
        super.init(coder: aDecoder)
    }
    
    private func setupView() {
        addSubview(suggestionLabel)
        addSubview(placeMarkStackView)
        addSubview(textFieldStackView)
        textFieldStackView.addArrangedSubview(firstPlaceTextField)
        textFieldStackView.addArrangedSubview(secondPlaceTextField)
        placeMarkStackView.addArrangedSubview(firstPlaceMarkImage)
        placeMarkStackView.addArrangedSubview(secondPlaceMarkImage)
    }
    
    private func setupConstraints() {
        
        suggestionLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(50)
        }
        placeMarkStackView.snp.makeConstraints {
            $0.top.equalTo(suggestionLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(30)
            $0.bottom.equalToSuperview().offset(-30)
        }
        
        textFieldStackView.snp.makeConstraints {
            $0.top.equalTo(suggestionLabel.snp.bottom)
            $0.trailing.bottom.equalToSuperview().offset(-30)
            $0.leading.equalTo(placeMarkStackView.snp.trailing).offset(30)
        }
        
        firstPlaceMarkImage.snp.makeConstraints {
            $0.height.width.equalTo(40)
        }
    }
    
    func setupUserLocationText(address: String) {
        firstPlaceTextField.text = address
    }
}
