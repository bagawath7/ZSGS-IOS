//
//  ResultViewController.swift
//  BMI Calculator
//
//  Created by zs-mac-4 on 04/10/22.
//

import UIKit
protocol ResultViewControllerDelegate : AnyObject{
    func getDetailsFromParent()->BMI?
    
}
class ResultViewController: UIViewController {
    
    var bmiValue: String?
    var advice: String?
    var color: UIColor?
    var delegate : ResultViewControllerDelegate?
    var bmi:BMI?


    @IBOutlet weak var adviceLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
         if let  bmi = delegate?.getDetailsFromParent(){
            
            bmiLabel.text = String(format: "%.2f", bmi.value)
            adviceLabel.text = bmi.advice
            view.backgroundColor = bmi.color
        }
    }
   
    @IBAction func BacktoController(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
