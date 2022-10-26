//
//  NextViewController.swift
//  ClassAboutAttributes
//
//  Created by zs-mac-4 on 22/09/22.
//

import UIKit

protocol NextViewControllerDelegate : AnyObject{
    func gotTheText(text : String)
    func getDetailsFromParent()->String
    
}




class NextViewController: UIViewController {

    
    var delegate : NextViewControllerDelegate?
    
    
    deinit{
        print("deinit of NextViewController")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button.center = self.view.center
        button.setTitle("Close", for: .normal)
        view.addSubview(button)
        button.addTarget(self, action: #selector(closeThisController(sender: )), for: .touchUpInside)
        
        
        let field = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        field.center = button.center
        field.center.y = button.center.y - 200
        field.layer.borderColor = UIColor.yellow.cgColor
        field.layer.borderWidth = 2.0
        view.addSubview(field)
        field.tag = 101
        
        
        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        button1.center = self.view.center
        button1.center.y = self.view.center.y + 200
        button1.setTitle("Get", for: .normal)
        view.addSubview(button1)
        button1.addTarget(self, action: #selector(getFromParent(sender: )), for: .touchUpInside)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    fileprivate func extractedFunc() {
        if let field = self.view.viewWithTag(101) as? UITextField{
            delegate?.gotTheText(text: field.text ?? "")
        }
    }
    
    @objc func closeThisController(sender : UIButton){
        self.dismiss(animated: true)
        extractedFunc()
    }
    
    @objc func getFromParent(sender : UIButton){
       let detail =  delegate?.getDetailsFromParent()
        print(detail)
    }
}
