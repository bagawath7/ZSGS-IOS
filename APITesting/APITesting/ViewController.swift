//
//  ViewController.swift
//  APITesting
//
//  Created by zs-mac-4 on 06/10/22.
//

import Foundation
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var todostable : UITableView!
    
    var todos = [Dictionary<String,Any>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchTodos()
        setupTable()
        
    }
    
    func setupTable(){
        
        let nib = UINib(nibName: "TodoTableViewCell", bundle: nil)
        todostable.register(nib, forCellReuseIdentifier: "cell")
        todostable.estimatedRowHeight = 64
        todostable.rowHeight = UITableView.automaticDimension
        todostable.delegate = self
        todostable.dataSource = self
        
    }

    func fetchTodos(){
        
        let todosAPI = "https://jsonplaceholder.typicode.com/todos"
        let todosURL = URL(string: todosAPI)!
        let todosRequest = URLRequest(url: todosURL)
        
        let urlsession = URLSession.shared
       
        let todosDataTask = urlsession.dataTask(with: todosRequest) { jsondata, todosResponse, todosError in
            
            if let jd = jsondata{
                self.processTodosData(with: jd)
            }
            
        }
        todosDataTask.resume()
        
    }
    
    
    func processTodosData(with data : Data){
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [Dictionary<String,Any>]{
            todos = json
        }
        DispatchQueue.main.async {
            self.todostable.reloadData()
        }
    }

}



extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoTableViewCell
        let thisTodo = todos[indexPath.row]
        
        if let id = thisTodo["id"] as? Int, let title = thisTodo["title"] as? String{
            cell.id.text = "\(id)"
            cell.title.text = title
            
            if indexPath.row == 100{
                cell.title.text = "\(title)  \n \n \(title)\n \n \(title)  \n \n \(title) \n \n \(title)  \n \n \(title)"
            }
        }
        
        return cell
    }
    
    
    
}


