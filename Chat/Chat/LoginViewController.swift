//
//  LoginViewController.swift
//  Chat
//
//  Created by zs-mac-4 on 10/10/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextLabel: UITextField!
    @IBOutlet weak var emailTextLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButton(_ sender: UIButton) {
        if let email = emailTextLabel.text,let password = passwordTextLabel.text{
            Auth.auth().signIn(withEmail: email, password: password){
                 authResult,error in
                    if let e = error{
                        print(e)
                    }else{
                        self.performSegue(withIdentifier: "login", sender: self)
                    }
            }
        }
       
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
