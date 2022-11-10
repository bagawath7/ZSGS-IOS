//
//  RegistrationViewController.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 01/11/22.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    weak var delegate:AuthenticationDelegate?
    var viewmodel = Registration.ViewModel()
    var profileImage:UIImage?
    
    
    
    lazy var plushPhotoButton:UIButton = {
        let button = UIButton()
        
    
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfileImage) , for: .touchUpInside)
        return button
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
    
    let fullnameTextfield: UITextField = CustomTextField(placeholder: "Fullname")
    let usernameTextField:UITextField = CustomTextField(placeholder: "Username")
       
    lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.3), for: .normal)
        button.backgroundColor = UIColor(red: 22/255, green: 44/255, blue: 70/255, alpha: 0.5)
        button.isEnabled = false
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
   lazy var  alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(alreadyHaveAccountButtonPressed), for: .touchUpInside)
        button.attributedTitle(firstPart: "Already have an account?", secondPart: "Login Up")
        return button
    }()
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setup()
        observeChanges()
        layout()

        
    }
    
    func setup(){
        
        
    }
  
    func layout(){
        
        
    //MARK: PlushPhotoButton
    
        view.addSubview(plushPhotoButton)
        plushPhotoButton.centerX(inView: view)
        plushPhotoButton.setDimensions(height: 140, width: 140)
        plushPhotoButton.anchor(top:  view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        
        
        //MARK: Text Field stack
        
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,fullnameTextfield,usernameTextField,signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        
        stack.anchor(top: plushPhotoButton.bottomAnchor,left: view.leadingAnchor,right: view.trailingAnchor,paddingTop: 32,paddingLeft: 32,paddingRight: 32)
        
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: self.view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }

}

extension RegistrationViewController{
    
    func observeChanges(){
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullnameTextfield.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
    }
    
    @objc func handleSignUp(){
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return}
        guard let fullname = fullnameTextfield.text else { return }
        guard let username = usernameTextField.text else { return }
        let profileImage = self.profileImage ?? UIImage(systemName: "person")!
            
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        AuthService.registerUser(withCredentail: credentials){ error in
            if let error = error{
                print(error.localizedDescription)
                return
            }
            self.delegate?.authenticationDidComplete()

        }
        }
        
        
       
    
    
    
    
    @objc func alreadyHaveAccountButtonPressed(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender:UITextField){
        if sender == emailTextField{
            viewmodel.email = sender.text
        }
        else if sender == passwordTextField{
            viewmodel.password = sender.text
        }
        else if sender == fullnameTextfield{
            viewmodel.fullname = sender.text
        }
        else if sender == usernameTextField{
            viewmodel.username = sender.text
        }
        if(viewmodel.formIsvalid){
            signUpButton.isEnabled = true
        }else{
            signUpButton.isEnabled = false
        }
        signUpButton.backgroundColor = viewmodel.buttonBgColor
        signUpButton.setTitleColor(viewmodel.buttomTitleColor, for: .normal)
        
    }
    
    
    @objc func handleProfileImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true)
        
    }
    
    
    
}


extension RegistrationViewController:UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            profileImage = image
            plushPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            plushPhotoButton.layer.cornerRadius = plushPhotoButton.frame.size.width / 2
            plushPhotoButton.layer.masksToBounds = true
            plushPhotoButton.layer.borderColor = UIColor.white.cgColor
            plushPhotoButton.layer.borderWidth = 2
           
        }
        self.dismiss(animated: true, completion: nil)
    }
}
