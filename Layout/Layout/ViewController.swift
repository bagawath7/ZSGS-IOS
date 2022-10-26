//
//  ViewController.swift
//  Layout
//
//  Created by zs-mac-4 on 29/09/22.
//

import UIKit

class ViewController: UIViewController {
     var stackView : UIStackView!
     var  ImageView : UIImageView!
     var label : UILabel!
     var ImageName: String!
     var titleText: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleText = "All that we are arises with our thoughts. With our thoughts, we make the world"
        ImageName = "world"
        style()
        layout()
        // Do any additional setup after loading the view.
    }
    private func style() {
        view.backgroundColor = .systemBackground
        stackView = UIStackView()
    
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        // Image
        ImageView = UIImageView()
        ImageView.translatesAutoresizingMaskIntoConstraints = false
        ImageView.contentMode = .scaleAspectFit
        ImageView.image = UIImage(named: ImageName)
        
        // Label
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = titleText
    }
    
    private func layout() {
        stackView.addArrangedSubview(ImageView)
        stackView.addArrangedSubview(label)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1)
        ])
    }


}

