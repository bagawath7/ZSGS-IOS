//
//  ViewController.swift
//  UserDefaultsClass
//
//  Created by zs-mac-4 on 19/10/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var initialLabel : UILabel!
    
    
    let userdefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialLabel()
        // Do any additional setup after loading the view.
    }

    
    
    func setupInitialLabel(){
        
        let isShown = userdefaults.bool(forKey: "welcome_note_shown")
        
        if !isShown{
            initialLabel.text = "Hi There, Welcome."
            userdefaults.set(true, forKey: "welcome_note_shown")
            userdefaults.synchronize()
        }else{
            initialLabel.text = "Thanks for coming again"
        }
        
        
        
    }

    
    @IBAction func logout(sender : UIButton){
        
        userdefaults.removeObject(forKey: "welcome_note_shown")
        //immediate login happend
        setupInitialLabel()
    }
}

