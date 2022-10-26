//
//  ViewController.swift
//  CoreDataProject
//
//  Created by zs-mac-4 on 14/10/22.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func addStudentAction(_ sender: UIBarButtonItem) {
        present(alertController(actionType: "add"), animated: true)
    }
    @IBOutlet weak var tableView: UITableView!
    var student = ["Bagawath","Siva","Gopal"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        // Do any additional setup after loading the view.
    }
    func setupTable(){
        tableView.dataSource = self
        tableView.delegate = self
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        student.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        cell.textLabel?.text = student[indexPath.row]
        return cell
    }
    
    private func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "CoreData", message: "StudentInfo", preferredStyle: .alert)
        
        alertController.addTextField{
            (textField:UITextField) in
            textField.placeholder = "Name"
        }
        alertController.addTextField{
            (textField:UITextField) in
            textField.placeholder = "Lesson Type: IOS| Andriod"
        }
        let defaultAction = UIAlertAction(title: actionType.uppercased(), style:.default){(actiom)in
            
        }
        let cancelAction = UIAlertAction(title: "Cancel".uppercased(), style:.default){(actiom)in
            
        }
        
        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)
        
        
        return alertController
    }
    
    
}
