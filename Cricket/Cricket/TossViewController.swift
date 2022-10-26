//
//  NewViewController.swift
//  Cricket
//
//  Created by zs-mac-4 on 03/10/22.
//

import UIKit

class TossViewController: UIViewController {
    var selection : String!
    @IBOutlet weak var TossImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    var timer : Timer!
    var status:Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = "RESULT"
        resultLabel.isHidden = true
        timer = Timer()
        
    }
    
    @IBAction func coinButtonAction(_ sender: UIButton) {
        selection = sender.titleLabel?.text ?? " "
        status=Bool.random()
        doAnimations(TossImage)
        if status {
            TossImage.image = UIImage(named: "heads")
        }
        else{
            TossImage.image = UIImage(named: "tails")
        }
    }
    func doAnimations(_ button:UIImageView){
        let coinFlip=CATransition()
        resultLabel.isHidden = true
        coinFlip.startProgress=0.0
        coinFlip.endProgress=1.0
        coinFlip.type=CATransitionType(rawValue: "flip")
        coinFlip.subtype=CATransitionSubtype(rawValue: "fromTop")
        coinFlip.duration=0.2
        coinFlip.repeatCount=7
        button.layer.add(coinFlip,forKey: "transition")
        timer = Timer.scheduledTimer(timeInterval: 1.5, target:self, selector: #selector(result), userInfo:nil, repeats: false)
    }
    @objc func result(){
        if (status && selection == "Head")||(!status && selection == "Tail"){
            resultLabel.text = "You have Won the toss"
            
        }
        else{
            resultLabel.text = "You have lost the Toss"
            
        }
        
        resultLabel.isHidden = false
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.5, target:self, selector: #selector(nextPage), userInfo:nil, repeats: false)
    }
    @objc func nextPage(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let mvc = sb.instantiateViewController(withIdentifier: "HomePage") as? ViewController{
            self.navigationController?.pushViewController(mvc , animated: true)
            
            
        }
    }
}
