//
//  ViewController.swift
//  CoreDataClass
//
//  Created by zs-mac-4 on 26/10/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        
        
        let manager = DBManager()
        manager.createPeople(name: "Sivamanikandan", age: 21, city: "Chidambaram")
        
        
        let people = manager.fetchPeople()
        
        //manager.updateName(with: "Siva M")
        
        if let person = people.first{
            manager.delete(obj: person)
        }
        
        
    }
}

