//
//  ResultViewController.swift
//  Cricket
//
//  Created by zs-mac-4 on 11/10/22.
//

import UIKit
protocol ResultDelegate:AnyObject{
    func getFromParent()->String
}

class ResultViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!

    
    
    
    var delegate:ResultDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        resultLabel.text = delegate.getFromParent()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
