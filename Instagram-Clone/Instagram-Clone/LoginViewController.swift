//
//  ViewController.swift
//  hello
//
//  Created by zs-mac-4 on 10/10/22.
//

import UIKit
import Firebase


protocol LoginDisplayLogic:AnyObject{
    
    
}

protocol AuthenticationDelegate:AnyObject{
    func authenticationDidComplete()
    
}
class LoginViewController: UIViewController {
    
    var viewmodel = Login.ViewModel()
    weak var delegate:AuthenticationDelegate?
    let logoContainerView: UIImageView = {
        let logoImageView = UIImageView(image:UIImage(named: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        return logoImageView
     
    }()
    
    let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
        
    }()
    
    let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")       
        tf.isSecureTextEntry = true
        return tf
        
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(viewmodel.buttomTitleColor, for: .normal)
        button.backgroundColor = viewmodel.buttonBgColor
        
        button.isEnabled = false
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin) , for: .touchUpInside)
        return button
    }()
    
   lazy var  dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(dontHaveAccountButtonPressed), for: .touchUpInside)
        button.attributedTitle(firstPart: "Don't have an account?", secondPart: "Sign Up")
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password ?", secondPart: "Get help signing in.")
        return button
    }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setup()
        layout()
        observeChanges()
        style()
        // Do any additional setup after loading the view.
        
    }
    
    
    
    func setup(){
        
    }
    
    func layout(){
        view.addSubview(logoContainerView)
        logoContainerView.centerX(inView: self.view)
        logoContainerView.setDimensions(height: 80, width: 120)
        logoContainerView.anchor(top:view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton,forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        
        stack.anchor(top: logoContainerView.bottomAnchor,left: view.leadingAnchor,right: view.trailingAnchor,paddingTop: 32,paddingLeft: 32,paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: self.view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        
    }
    func style(){
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        
        
          
    }
    
}


extension LoginViewController{
    
    func observeChanges(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
    }
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return}
        AuthService.logUserIn(withEmail: email, password: password){ authResult, error in
            if let e = error {
                print(e)
            } else {
                self.delegate?.authenticationDidComplete()
            }
          // ...
        }
        }
    @objc func  dontHaveAccountButtonPressed(){
        let nextVC = RegistrationViewController()
        nextVC.delegate = delegate
        self.navigationController?.pushViewController(
            nextVC, animated: true)
        
    }
    @objc func textDidChange(sender:UITextField){
        if sender == emailTextField{
            viewmodel.email = sender.text
        }
        else if sender == passwordTextField{
            viewmodel.password = sender.text
        }
      
        if(viewmodel.formIsvalid){
            loginButton.isEnabled = true
        }else{
            loginButton.isEnabled = false
        }
        loginButton.backgroundColor = viewmodel.buttonBgColor
        loginButton.setTitleColor(viewmodel.buttomTitleColor, for: .normal)
        
    }
    
}
