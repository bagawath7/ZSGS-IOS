//
//  ViewController.swift
//  Animate
//
//  Created by zs-mac-4 on 30/09/22.
//

import UIKit

class ViewController: UIViewController {

    var Button : UIButton!
        let distanceToMove = 100.0
       
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        addRectangle()
        addButtons()
    }
    
    
    
    
        
    
    func addRectangle(){
        Button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        Button.backgroundColor = .black
        Button.center = self.view.center
        self.view.addSubview(Button)
    }

    
    
    func addButtons(){
        let actions = ["Up", "Down", "Left", "Right"]
        var tag = 1
        var x = 0.0
        for action in actions{
            let Btn = UIButton(frame: CGRect(x: x, y: self.view.frame.maxY - 64.0, width: self.view.frame.width/4.0 , height: 44.0))
            Btn.setTitle(action, for: .normal)
            Btn.setTitleColor(.black, for: .normal)
            Btn.layer.borderWidth = 1.0
            Btn.layer.borderColor = UIColor.gray.cgColor
            Btn.addTarget(self, action: #selector(moveRectangle(sender:)), for: .touchUpInside)
            Btn.tag = tag
            tag = tag + 1
            self.view.addSubview(Btn)
                        x += self.view.frame.width/4.0
        }
    }
    
    @objc func moveRectangle(sender : UIButton){
         let tag = sender.tag
            var center = Button.center
            
            if tag == 2{
                center.y -= distanceToMove
            }else if tag == 1{
                center.y += distanceToMove
            }else if tag == 4{
                center.x -= distanceToMove
            }else if tag == 3{
                center.x += distanceToMove
            }
            
            UIView.animate(withDuration: 1) {
                self.Button.center = center
            }
            
            Button.center = self.view.center

            
        }
    }


