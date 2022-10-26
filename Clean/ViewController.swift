//
//  ViewController.swift
//  Instagram
//
//  Created by zs-mac-4 on 26/10/22.
//

import UIKit

protocol DisplayLogic:AnyObject{
    
}

class RenameViewController: UIViewController {
    
    var intractor:BussinessLogic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        
        let intractor = Intractor()
        let presenter = Presenter()
        
        intractor.presenter = presenter
        presenter.viewController = self
        self.intractor = intractor
        
        
        
    }

}


extension RenameViewController:DisplayLogic{
    
    
}
