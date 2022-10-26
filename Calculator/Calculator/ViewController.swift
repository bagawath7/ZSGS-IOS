//
//  ViewController.swift
//  Calculator
//
//  Created by zs-mac-4 on 19/09/22.
//

import UIKit
class ViewController: UIViewController {
    var displayLabel:UILabel!
    var buttomView:UIView!
    var button:UIButton!
    var totalHeight:CGFloat!
    var val = 0
    var prevInput:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtonView()
        addButtons()
        addLable()

        
    }
    private func addButtons(){
        let buttons:[[String]]=[["7","8","9","X"],["4","5","6","-"],["1","2","3","+"],["%","0","AC","="]]
        var y = CGFloat(0)
        let height = buttomView.frame.height / 4
        let width = self.view.frame.width / 4
        for i in 0...buttons.count-1{
            var x = CGFloat(0)
            for j in buttons[i]{
                self.addButton(x, y, j)
                x = width + x;
            }
            y = height + y
        }
    }
    private func addButton(_ x:CGFloat,_ y:CGFloat,_ string:String){
        let width = self.view.frame.width / 4
        let height = buttomView.frame.height / 4
        button = UIButton()
        buttomView.addSubview(button)
        button.frame = CGRect(x: x,y: y, width: width, height: height)
        button.backgroundColor = UIColor.black
        button.showsTouchWhenHighlighted = true
        button.setTitle(string, for: .normal)
        button.addTarget(self, action: #selector(addToDisplayLable(sender:)), for: .touchUpInside)

    }
    func addLable(){
            
            let mainFrame=self.view.frame
            displayLabel=UILabel()
            let height=mainFrame.height-(mainFrame.height*CGFloat(75))/CGFloat(100)
            self.view.addSubview(displayLabel)


            displayLabel.textAlignment=NSTextAlignment.right
            displayLabel.text=""
            displayLabel.textColor=UIColor.black
            displayLabel.backgroundColor=UIColor.white
            displayLabel.font=displayLabel.font.withSize(50)
        displayLabel.frame=CGRect(x:0,y:0,width:mainFrame.width,height:height)
        }

    private func addButtonView(){
        let height = self.view.frame.height * (3/4)
        totalHeight = CGFloat(self.view.frame.height)
        let width = self.view.frame.width
        buttomView = UIView()
        self.view.addSubview(buttomView)
        buttomView.backgroundColor = UIColor.red
        buttomView.frame = CGRect(x: 0, y: totalHeight-height, width: width, height: height)
    }
    private func add(_ a:Int,_ b:Int)->Int{
        return a+b
    }
    private func sub(_ a:Int,_ b:Int)->Int{
        return a-b
    }
    private func mul(_ a:Int,_ b:Int)->Int{
        return a*b
    }
    private func div(_ a:Int,_ b:Int)->Int{
        return a/b
    }
    @objc func addToDisplayLable(sender:UIButton){
        
        let input=sender.title(for: .normal)
        let string=displayLabel.text!
        displayLabel.text=displayLabel.text!+input!
        if(input=="AC"){
            displayLabel.text=""
            val=0
        }
        else if (input=="+"||input=="-"||input=="X"||input=="%"){
            prevInput = input
            let start = string.index(string.startIndex, offsetBy: 0)
            let end = string.index(string.endIndex, offsetBy: -1 )
            let range = start...end
            let subStr = string[range]
            print(subStr)
            val = Int(subStr)!
            displayLabel.text=""
            
        }
        if(input=="="){
            let start = string.index(string.startIndex, offsetBy: 0)
            let end = string.index(string.endIndex, offsetBy: -1 )
            let range = start...end
            let subStr = string[range]
            switch(prevInput){
            case "+": val = add(val,Int(subStr)!)
            case "-": val = sub(val,Int(subStr)!)
            case "%": val = div(val,Int(subStr)!)
            case "X": val = mul(val,Int(subStr)!)
            case .none:
                print("hello")
            case .some(_):
                print("some")
            }
            let result = String(val)
            displayLabel.text=result
            
        }
        
        
        
        
        
        
    }
            }
            


