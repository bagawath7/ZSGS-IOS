//
//  CustomTextField.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 31/10/22.
//
import UIKit
import Foundation

class CustomTextField:UITextField {
    
       init(placeholder: String) {
        super.init(frame: .zero)
           
        let spacer = UIView()
           spacer.setDimensions(height: 50, width: 8)
           leftView = spacer
           leftViewMode = .always
        attributedPlaceholder = NSAttributedString(string: placeholder,attributes: [.foregroundColor:UIColor(white: 1, alpha: 0.7)])
        textColor = .white
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        borderStyle = .roundedRect
        font = UIFont.systemFont(ofSize: 14)
        keyboardAppearance = .dark
        tintColor = .white
        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
        setHeight(50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
