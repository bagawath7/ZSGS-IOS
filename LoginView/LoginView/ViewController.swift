//
//  ViewController.swift
//  LoginView
//
//  Created by zs-mac-4 on 22/09/22.
//

import UIKit

class ViewController: UIViewController {
    let loginView = UIView()
    let stackView = UIStackView()
    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    let dividerView = UIView()
    let errorMessageLabel = UILabel()
    let signInButton = UIButton(type: .system)
    var userInfo = ["Bagawath": "Hello", "Siva": "xyz", "Gopal": "abc"]




    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        }
}
extension ViewController {
    
    private func style() {
        loginView.translatesAutoresizingMaskIntoConstraints = false
        loginView.backgroundColor = .secondarySystemBackground
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.placeholder = "Username"
        usernameTextField.delegate = self

        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = .secondarySystemFill

        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
                
        loginView.layer.cornerRadius = 5
        loginView.clipsToBounds = true
        
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.configuration = .filled()
        signInButton.configuration?.imagePadding = 8 // for indicator spacing
        signInButton.setTitle("Sign In", for: [])
        signInButton.addTarget(self, action: #selector(signInTapped), for: .primaryActionTriggered)

        errorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorMessageLabel.textAlignment = .center
        errorMessageLabel.textColor = .systemRed
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.isHidden = true

        
    }
    private func layout(){
        view.addSubview(loginView)
        view.addSubview(signInButton)
        view.addSubview(errorMessageLabel)

        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(passwordTextField)

        loginView.addSubview(stackView)
        //loginView
        NSLayoutConstraint.activate([
            loginView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: loginView.trailingAnchor, multiplier: 2),
            view.centerYAnchor.constraint(equalTo: loginView.centerYAnchor),
        ])
        // StackView
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow:loginView.topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter:loginView.leadingAnchor, multiplier: 1),
            loginView.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            loginView.bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 1)
        ])
        
        // Error message
        NSLayoutConstraint.activate([
            errorMessageLabel.topAnchor.constraint(equalToSystemSpacingBelow: signInButton.bottomAnchor, multiplier: 2),
            errorMessageLabel.leadingAnchor.constraint(equalTo: loginView.leadingAnchor),
            errorMessageLabel.trailingAnchor.constraint(equalTo: loginView.trailingAnchor)
        ])
        
        // Button
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalToSystemSpacingBelow: loginView.bottomAnchor, multiplier: 2),
            signInButton.leadingAnchor.constraint(equalTo: loginView.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: loginView.trailingAnchor),
        ])

        
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

extension ViewController {
    @objc func signInTapped(sender: UIButton) {
        errorMessageLabel.isHidden = true
        login()
    }
    private func configureView(withMessage message: String) {
        errorMessageLabel.isHidden = false
        errorMessageLabel.text = message
    }
    private func login() {
        let user = usernameTextField.text!
        let pass = passwordTextField.text!
        
        if user.isEmpty || pass.isEmpty {
            configureView(withMessage: "Username / password cannot be blank")
            return
        }
        
        
        if(userInfo[user]==pass){
            let tabVC = UITabBarController()
            tabVC.modalPresentationStyle = .fullScreen
            
            tabVC.tabBar.backgroundColor = .white
            
            let vc1 = FirstviewController()
            let vc2 = SecondviewController()
            let vc3 = ThirdviewController()
            let vc4 = FourthviewController()
            vc1.title = "Home"
            vc2.title = "Help"
            vc3.title = "About"
            vc4.title = "Setting"
            
            
            
            tabVC.setViewControllers([vc1,vc2,vc3,vc4], animated: false)
            tabVC.modalPresentationStyle = .fullScreen
            present(tabVC, animated: true)
            let items = tabVC.tabBar.items!
            let images = ["house","bell","person.circle","gear"]
            for i in 0..<items.count{
                items[i].image = UIImage(systemName: images[i])
            }
            
            
        }else {
            configureView(withMessage: "Incorrect username / password")
        }
        
    }
    
}

class FirstviewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}
class SecondviewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
    }
}
class ThirdviewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
    }
}
class FourthviewController:UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}


