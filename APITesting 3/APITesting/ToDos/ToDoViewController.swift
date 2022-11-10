//
//  ToDoViewController.swift
//  APITesting
//
//  Created by zs-mac-4 on 19/10/22.
//

import UIKit
 
protocol ToDoDisplayLogic : AnyObject{
    func update(viewmodel : ToDoModel.ViewModel!)
} 


class ToDoViewController: UIViewController,ToDoDisplayLogic{
    
    

    @IBOutlet weak var todostable : UITableView!
    
    
    var intractor : ToDoBusinessLogic!
    
    var viewModel : ToDoModel.ViewModel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = .cyan
         setup()
            setupTable()
                startTodos()
        
    }
    
    
    func setup(){
        let intractor = ToDoIntractor()
        let presenter = ToDoPresenter()
        intractor.presenter = presenter
        presenter.viewcontroller = self
        self.intractor = intractor
    }
    
    
    func startTodos(){
        intractor?.fetchToDos()
        
    }
    
    func setupTable(){
        
        let nib = UINib(nibName: "TodoTableViewCell", bundle: nil)
        todostable.register(nib, forCellReuseIdentifier: "cell")
        todostable.estimatedRowHeight = 64
        todostable.rowHeight = UITableView.automaticDimension
        todostable.delegate = self
        todostable.dataSource = self
        todostable.backgroundColor = .white
        
    }
    
    
    func update(viewmodel: ToDoModel.ViewModel!) {
        self.viewModel = viewmodel
        todostable.reloadData()
    }

}


extension ToDoViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.objects.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoTableViewCell
        
        let todo = self.viewModel.objects[indexPath.row]
        cell.id.text = "\(todo.id)"
        cell.title.text = todo.title
        cell.contentView.backgroundColor = .white
    
        return cell
        
        
        
    }
    
    
}
