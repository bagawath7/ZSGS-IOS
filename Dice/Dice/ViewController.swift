//
//  ViewController.swift
//  Dice
//
//  Created by zs-mac-4 on 30/09/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var ImageView2: UIImageView!
    @IBOutlet weak var ImageView1: UIImageView!
    @IBOutlet weak var Label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func Roll(_ sender: Any) {
        let diceArray = ["DiceOne","DiceTwo","DiceThree","DiceFour","DiceFive","DiceSix"]
        let dice1 = Int.random(in: 0...5)
        let dice2 = Int.random(in: 0...5)

        ImageView1.image = UIImage(named: diceArray[dice1])
        ImageView2.image = UIImage(named: diceArray[dice2])
        Label.text = String((dice1+1) + (dice2+1)
)
        
        
    }
    
}

