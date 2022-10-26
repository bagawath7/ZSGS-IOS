//
//  PeopleListViewController.swift
//  PeopleList
//
//  Created by zs-mac-4 on 23/09/22.
//

import UIKit


class PeopleListViewController: UIViewController {
    
    
    var peopleTable : UITableView!
    let peopleSection = ["S","B","N"]
    let peopleNames : [[String]] = [
        ["Santhosh","Sakthi","Siva","Saravana Velu"],
        ["Bagawath","Barani","Barathi"],
        ["Nisha","Nithya"]
    ]
    let peoplePic : [[String]] = [["user0","user1","user3","user6"],
                                  ["user4","user2","user5"],
                                  ["user6","user0"]]
    let peoplePosition : [[String]] = [["IOS Developer","Developer","UI/UX Designer","App Developer"],
    ["IOS Developer","UI/UX Designer","UI/UX Designer"],
    ["Tech Writer","Tech Writer"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "People list"
        setupTableView()
        
    }
    

    
    func setupTableView(){
        peopleTable = UITableView(frame: .zero, style: .grouped)
        peopleTable.frame = CGRect(x: 0, y: 84, width: self.view.frame.width, height:  self.view.frame.height - 84)
        self.view.addSubview(peopleTable)
        
        
        let nib = UINib(nibName: "PeopleTableViewCell", bundle: nil)
        peopleTable.register(nib, forCellReuseIdentifier: "cell")
        
        //peopleTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        peopleTable.delegate = self
        peopleTable.dataSource = self
        
        
    }

}


extension PeopleListViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return peopleSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentRows = peopleNames[section]
        return currentRows.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PeopleTableViewCell
        let currentRows = peopleNames[indexPath.section]
        let currentName = currentRows[indexPath.row]
        let currentPosition = peoplePosition[indexPath.section][indexPath.row]
        let currentpic = peoplePic[indexPath.section][indexPath.row]
        cell.username.text = currentName
        cell.userrole.text = currentPosition
        cell.userimage.image = UIImage(named: currentpic)
        
        
        let image_name = "user\(indexPath.row).jpeg"
        var uimage = UIImage(named: image_name)
        if uimage == nil {
            uimage = UIImage(named: "user1.jpeg")
        }
        cell.userimage.image = uimage

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
}
