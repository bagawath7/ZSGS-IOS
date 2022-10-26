//
//  OnboardingViewController.swift
//  Bankey
//
//  Created by jrasmusson on 2021-09-30.
//

import UIKit

class OnboardingView: UIViewController {
    
    let stackView = UIStackView()
    let ImageView = UIImageView()
    let label = UILabel()
    
    let Image: String
    let content: String
    
    init(Image: String, content: String) {
        self.Image = Image
        self.content = content
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
}

extension OnboardingView {
    func style() {
        view.backgroundColor = .systemBackground
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        // Image
        ImageView.contentMode = .scaleAspectFit
        ImageView.image = UIImage(named: Image)
        
        // Label
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.text = content
    }
    
    func layout() {
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
