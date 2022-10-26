//
//  RegisterViewController.swift
//  Chat
//
//  Created by zs-mac-4 on 10/10/22.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text,let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password){
            authResult,error in
                if let e = error{
                    print(e.localizedDescription)
                }else{
                    self.performSegue(withIdentifier: "signUp", sender: self)
                }
            }

        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
