//
//  ViewController.swift
//  CustomizableTableView
//
//  Created by zs-mac-4 on 26/09/22.
//

import UIKit

class Contact: UIViewController {
    var peopleTable : UITableView!
    
    let peopleSection = ["S","B","R"]
    let peopleNames : [[String]] = [
        ["Santhosh","Sakthi","Siva"],
        ["Bagawath","Barani","Barathi"],
        ["Nisha","Rebecca"]
    ]
    let peoplePic : [[String]] = [["user0","user1","user3"],
                                  ["user4","user2","user5"],
                                  ["user6","user0"]]
    let peoplePosition : [[String]] = [["IOS Developer","Developer","UI/UX Designer"],
    ["IOS Developer","UI/UX Designer","UI/UX Designer"],
    ["Tech Writer","Tech Writer"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

    }
    func setupTableView(){
        peopleTable = UITableView(frame: .zero, style: .grouped)
        peopleTable.frame = CGRect(x: 0, y: 84, width: self.view.frame.width, height:  self.view.frame.height - 84)
        self.view.addSubview(peopleTable)
        
        let nib = UINib(nibName: "ContactsTableViewCell", bundle: nil)
        peopleTable.register(nib, forCellReuseIdentifier: "cell")
        peopleTable.delegate = self
        peopleTable.dataSource = self
        
        
    }


}
extension Contact : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return peopleSection.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentRows = peopleNames[section]
        return currentRows.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactsTableViewCell
        let currentRows = peopleNames[indexPath.section]
        let currentName = currentRows[indexPath.row]
        let currentPosition = peoplePosition[indexPath.section][indexPath.row]
        let currentpic = peoplePic[indexPath.section][indexPath.row]
        cell.Name.text = currentName

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return peopleSection[section]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
}

