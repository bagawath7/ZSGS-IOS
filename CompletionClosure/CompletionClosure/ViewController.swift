//
//  ViewController.swift
//  CompletionClosure
//
//  Created by zs-mac-4 on 14/10/22.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    var todos  = [ToDo]()
    let apimanager = APIManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
       // fetchTodos()
        
        apimanager.fetchTodos { tds in
            self.todos = tds
            DispatchQueue.main.async {
                self.updateTable()
            }
        } failure: { error in
            print(error)
        }

        
        print("last line")
    }
    
    
    func updateTable(){
        
        if let todo = todos.first{
            titleLabel.text = todo.title
        }
        
    }
    
    
    
   
    
    
}

