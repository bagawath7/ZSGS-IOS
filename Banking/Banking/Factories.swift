//
//  Factories.swift
//  Banking
//
//  Created by zs-mac-4 on 13/10/22.
//

import Foundation
import UIKit

// MARK: - Labels

func makeLabel(withText text: String) -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false // important!
    label.textAlignment = .center
    label.numberOfLines = 0
    label.text = text
    
    return label
}

func makeLabel(withText text: String, size: CGFloat) -> UILabel {
    let label = makeLabel(withText: text)
    label.font = UIFont.systemFont(ofSize: size)
    
    return label
}

func makeLabel(withText text: String, size: CGFloat, color: UIColor) -> UILabel {
    let label = makeLabel(withText: text, size: size)
    label.backgroundColor = color
    
    return label
}

func makeSecondaryLabel(withText text: String) -> UILabel {
    let label = makeLabel(withText: text, size: 12)
    label.textColor = .gray
    
    return label
}

// MARK: - Buttons

// Old - pre iOS 15
/*
 func makeButton(withText text: String) -> UIButton {
 let button = UIButton()
 button.translatesAutoresizingMaskIntoConstraints = false
 button.setTitle(text, for: .normal)
 button.titleLabel?.adjustsFontSizeToFitWidth = true
 button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
 button.backgroundColor = .blue
 button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
 
 return button
 }
 */

func makeButton(withText text: String) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle(text, for: .normal)
    
    var config = UIButton.Configuration.filled()
    config.baseBackgroundColor = .systemBlue
    config.cornerStyle = .capsule
    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    button.configuration = config
    return button
}

func makeButton(withText text: String, size: CGFloat = 18, color: UIColor = .blue) -> UIButton {
    let button = makeButton(withText: text)
    button.backgroundColor = color
    button.titleLabel?.font = UIFont.systemFont(ofSize: size)
    
    return button
}

func makeButton(withText text: String, color: UIColor) -> UIButton {
    let button = makeButton(withText: text)
    button.backgroundColor = color
    
    return button
}

// MKAR: - Misc

func makeTextField(withPlaceholderText placeHolderText: String) -> UITextField {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = placeHolderText
    return textField
}

func makeStackView(withOrientation axis: NSLayoutConstraint.Axis) -> UIStackView {
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = axis
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.spacing = 8.0
    
    return stackView
}

func makeView(color: UIColor = .red) -> UIView {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = color
    
    return view
}

func makeSwitch(isOn: Bool) -> UISwitch {
    let theSwitch = UISwitch()
    theSwitch.translatesAutoresizingMaskIntoConstraints = false
    theSwitch.isOn = isOn
    
    return theSwitch
}

func makeScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    
    return scrollView
}

public func makeSpacerView(height: CGFloat? = nil) -> UIView {
    let spacerView = UIView(frame: .zero)
    
    if let height = height {
        spacerView.heightAnchor.constraint(equalToConstant: height).setActiveBreakable()
    }
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    
    return spacerView
}

public extension NSLayoutConstraint {
    @objc func setActiveBreakable(priority: UILayoutPriority = UILayoutPriority(900)) {
        self.priority = priority
        isActive = true
    }
}
