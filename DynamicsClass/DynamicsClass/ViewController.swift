//
//  ViewController.swift
//  DynamicsClass
//
//  Created by zs-mac-4 on 20/10/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var button : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    
    func setup(){
        
        
        label.text = "Hello World"
        label.layer.cornerRadius = 10.0
        label.backgroundColor = UIColor(named: "labelcolor")
        
        
        button.backgroundColor = UIColor(named: "buttoncolor")
        button.setTitle("Pay Now", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10.0
    }

}

