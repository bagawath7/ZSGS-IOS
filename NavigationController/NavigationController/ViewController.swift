//
//  ViewController.swift
//  NavigationController
//
//  Created by zs-mac-4 on 21/09/22.
//
 
import UIKit

class ViewController: UIViewController{
    
    var Username:UITextField!
    var Password:UITextField!
    var button:UIButton!
    var invalid:UILabel!
    var userInfo = ["Bagawath": "Hello", "Siva": "xyz", "Gopal": "abc"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        Username=createTextField(300,"Enter the username")
        Password=createTextField(350,"Enter the password")
        Password.isSecureTextEntry=true

            addSubmit(20, 430, "Submit")
        invalid = UILabel(frame: (CGRect(x: 40, y: 400, width: 250, height: 12)))
        invalid.text = "Invaild password/username"
        invalid.textColor = UIColor.red
        view.addSubview(invalid)
        invalid.isHidden = true

    }
    
    
    
    func createTextField(_ y:Int,_ string:String)->UITextField{
        var Username =  UITextField(frame: CGRect(x: 20, y: y, width: 300, height: 40))
        Username.placeholder = string
        Username.text=""
        Username.font = UIFont.systemFont(ofSize: 15)
        Username.borderStyle = UITextField.BorderStyle.roundedRect
        Username.autocorrectionType = UITextAutocorrectionType.no
        Username.keyboardType = UIKeyboardType.default
        Username.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.view.addSubview(Username)
        return Username
        
    }
    private func addSubmit(_ x:CGFloat,_ y:CGFloat,_ string:String){
        let width = self.view.frame.width / 4
        button = UIButton()
        view.addSubview(button)
        button.frame = CGRect(x: width+40,y: y, width: 100, height: 44)
        button.backgroundColor = UIColor.black
        button.showsTouchWhenHighlighted = true
        button.setTitle(string, for: .normal)
        button.addTarget(self, action: #selector(submit), for: .touchUpInside)

    }
    @objc func submit(){
        let user = Username.text!
        let pass = Password.text
        if(userInfo[user]==pass){
            let nextVC = NextViewController()
//            nextVC.nextVC.delegate = self
            nextVC.delegate = self
            let nav = self.navigationController!
                nav.pushViewController(nextVC, animated: true)
            }else {
                invalid.isHidden = false
                Username.text = ""
                Password.text = ""
                print("false")
            
        }
        
    }


}
extension ViewController : NextViewControllerDelegate{
    
    func gotTheText(user: String, pass:String) {
        Username.text = user
        Password.text = pass
        print(user)
    }
}
