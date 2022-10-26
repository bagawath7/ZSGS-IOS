//
//  LoginView.swift
//  Banking
//
//  Created by zs-mac-4 on 13/10/22.
//

import Foundation
import UIKit

class LoginView: UIView {
    let usernameTextField = makeTextField(withPlaceholderText: "Enter the Username: ")
    let passwordTextField = makeTextField(withPlaceholderText: "Enter the Password: ")
    let dividerView = UIView()
    let stackView = makeStackView(withOrientation: .vertical)
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        style()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}

extension LoginView {
    func style() {
        translatesAutoresizingMaskIntoConstraints = false
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .secondarySystemBackground
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .secondarySystemFill

        passwordTextField.isSecureTextEntry = true
        passwordTextField.enablePasswordToggle()
                
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    func layout() {
        addSubview(stackView)
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -8)
        ]
                        
        )
        
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
}


let passwordToggleButton = UIButton(type: .custom)

extension UITextField {
    
    func enablePasswordToggle(){
        passwordToggleButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        passwordToggleButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        rightView = passwordToggleButton
        rightViewMode = .always
    }
    
    @objc func togglePasswordView(_ sender: Any) {
        isSecureTextEntry.toggle()
        passwordToggleButton.isSelected.toggle()
    }
}
