//
//  ViewController.swift
//  ClassAboutAttributes
//
//  Created by zs-mac-4 on 22/09/22.
//

import UIKit





class ViewController: UIViewController {

    var stringFromAnotherContrller : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addItems()
        self.view.backgroundColor = UIColor.green
    }

    
    func addItems(){
        
        var y = 100
        for i in 0..<10{
            let button = UIButton(frame: CGRect(x: Int(self.view.frame.width / 2.0 - 100.0), y: y, width: 200, height: 44))
            button.backgroundColor = UIColor(red: 30.0 / 255.0 , green: 40.0 / 255.0, blue: 50.0 / 255.0, alpha: CGFloat(Double((i + 1)) / 10.0))
            y += 54
            self.view.addSubview(button)
            
            
            button.layer.cornerRadius = 6.0
            button.setTitle("no : \(i)", for: .normal)
            button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
            button.tag = 1000 + i
        }
        
        
        let label = UILabel(frame: CGRect(x: Int(self.view.frame.width / 2.0 - 100.0), y: y + 100, width: 200, height: 44))
        label.textAlignment = .center
        label.text = "No button clicked"
        self.view.addSubview(label)
        label.tag = 2000
        
    }
    
    
    @objc func buttonClicked(sender : UIButton){
        
        if let addedLabel = self.view.viewWithTag(2000) as? UILabel{
            
            let tappedButton = sender.tag - 1000
            
            addedLabel.text = "Clicked button is \(tappedButton)"
            
            let nextvc = NextViewController()
            nextvc.delegate = self
            nextvc.view.backgroundColor = sender.backgroundColor
            self.present(nextvc, animated: true)
        }
    }
    
    
}




extension ViewController : NextViewControllerDelegate{
    func getDetailsFromParent() -> String {
        return "hello there"
    }
    
    func gotTheText(text: String) {
        stringFromAnotherContrller = text
        
        print("got the text \(text) from nextviewcontroller using delegate")
    }
}
