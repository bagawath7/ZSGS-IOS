//
//  ViewController.swift
//  Banking
//
//  Created by zs-mac-4 on 13/10/22.
//

import UIKit



protocol LoginViewControllerDelegate: AnyObject {
    func didLogin(_ username:String,_ password:String)
}
class LoginViewController: UIViewController {
    let titleLabel = makeLabel(withText: "Bank")
    let subtitleLabel = makeLabel(withText: "Your premium source for all things banking!")

    let loginView = LoginView()
    let signInButton = UIButton(type: .system)
    let errorMessageLabel = makeLabel(withText: "")

    
    var username: String? {
        return loginView.usernameTextField.text
    }

    var password: String? {
        return loginView.passwordTextField.text
    }
    
    
    weak var delegate: LoginViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        layout()
        
        // Do any additional setup after loading the view.
    }
    func style(){
        view.backgroundColor = .systemBackground
        view.tintColor = .black
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.backgroundColor = .systemBackground
        titleLabel.adjustsFontForContentSizeCategory = true
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        subtitleLabel.backgroundColor = .systemBackground
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.numberOfLines = 0
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.configuration = .filled()
        signInButton.configuration?.imagePadding = 9// for indicator spacing
        signInButton.setTitle("Sign In", for: [])
        signInButton.tintColor = .black

        
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        
    }
        
    
    func layout(){
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(loginView)
        view.addSubview(signInButton)
        view.addSubview(errorMessageLabel)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
            titleLabel.centerXAnchor.constraint(equalTo: subtitleLabel.centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            loginView.topAnchor.constraint(equalToSystemSpacingBelow: subtitleLabel.bottomAnchor, multiplier: 2),
            subtitleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: loginView.leadingAnchor, multiplier: 0),
            loginView.trailingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            loginView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 8),
            view.trailingAnchor.constraint(equalTo: loginView.trailingAnchor,constant: 8)
        ])
        
        
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalToSystemSpacingBelow: loginView.bottomAnchor, multiplier: 2),
            signInButton.leadingAnchor.constraint(equalTo: loginView.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: loginView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            errorMessageLabel.topAnchor.constraint(equalToSystemSpacingBelow: signInButton.bottomAnchor, multiplier: 2),
            errorMessageLabel.leadingAnchor.constraint(equalTo: loginView.leadingAnchor),
            errorMessageLabel.trailingAnchor.constraint(equalTo: loginView.trailingAnchor)
        ])
        
    }
    
}

extension LoginViewController {
    @objc func signInTapped(sender: UIButton) {
        errorMessageLabel.isHidden = true
        login()
    }

    private func login() {
        guard let username = username, let password = password else {
            assertionFailure("Username / password should never be nil")
            return
        }

        if username.isEmpty || password.isEmpty {
            configureView(withMessage: "Username / password cannot be blank")
            return
        }

        if username == password  {
            signInButton.configuration?.showsActivityIndicator = true
            let accountSummaryVc = AccountSummaryViewController()
            delegate?.didLogin(username,password)

            
        } else {
            configureView(withMessage: "Incorrect username / password")
        }
    }

    private func configureView(withMessage message: String) {
        errorMessageLabel.isHidden = false
        errorMessageLabel.text = message
    }
}
