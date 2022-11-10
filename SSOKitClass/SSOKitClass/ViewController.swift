//
//  ViewController.swift
//  SSOKitClass
//
//  Created by zs-mac-4 on 08/11/22.
//

import UIKit
import SSOKit
class ViewController: UIViewController {

    
    @IBOutlet weak var loginbutton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if ZSSOKit.isUserSignedIn(){
            loginbutton.setTitle("Logout", for: .normal)
            loginbutton.tag = 101
            logUserDetails()
        }
        
        loginbutton.addTarget(self, action: #selector(tryLoggingIn(sender:)), for: .touchUpInside)
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
   
    }
    
    @objc func tryLoggingIn(sender : UIButton){
        if sender.tag != 101{
            ZSSOKit.presentInitialViewController { (accessToken, error) in
                if let err = error {
                    print(err)
                    //Handle login errors with proper alerts and redirection
                } else {
                    DispatchQueue.main.async {
                        self.loginbutton.setTitle("Logout", for: .normal)
                        self.loginbutton.tag = 101
                        self.logUserDetails()
                    }
                    print(accessToken)
                }
            }
        }else{
            logoutFromTheApp()
        }
    }
    
    func logoutFromTheApp(){
        ZSSOKit.revokeAccessToken { error in
            if error == nil{
                DispatchQueue.main.async {
                    self.loginbutton.setTitle("Login", for: .normal)
                    self.loginbutton.tag = 100
                }
            }
        }
    }
    
    func logUserDetails(){
        let email = ZSSOKit.getCurrentUser().profile.email ?? ""
        let username = ZSSOKit.getCurrentUser().profile.displayName ?? ""
        let zuid = ZSSOKit.getCurrentUser().userZUID ?? ""
        
        
        print("email - \(email)")
        print("username - \(username)")
        print("zuid - \(zuid)")
        
        getMyProfilePic()
    }
    
    
    
    func getMyProfilePic(){
        let zuid = ZSSOKit.getCurrentUser().userZUID ?? ""
        let myimageurl = "https://contacts.zoho.com/file/download?ID=\(zuid)"
        
        
        ZSSOKit.getOAuth2Token { token, error in
            if error == nil{
                if let t = token{
                    var urlreq = URLRequest(url: URL(string: myimageurl)!)
                    let tokenvalue = "Zoho-oauthtoken \(t)"
                    urlreq.setValue(tokenvalue, forHTTPHeaderField: "Authorization")

                    URLSession.shared.dataTask(with: urlreq) { data, resp, error in
                        DispatchQueue.main.async {
                            if let img = data{
                                self.updateImage(with: img)
                            }
                        }
                    }.resume()
                }
            }
        }
        
        
    }
    
    func updateImage(with img : Data){
        if let image = UIImage(data: img){
            
            let imageview = UIImageView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
            self.view.addSubview(imageview)
            imageview.image = image
        }else{
            print("no image received")
        }
        
        
    }
    
    
    
}

