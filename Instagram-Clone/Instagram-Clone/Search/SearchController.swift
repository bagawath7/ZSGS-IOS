//
//  ViewController.swift
//  Instagram
//
//  Created by parthiban-15607 on 03/11/22.
//

import UIKit
protocol SearchDisplayLogic:AnyObject{
    func updateUsers(users:[UserModel.ViewModel.User])
    
}
class SearchController: UITableViewController {
    let reuseIdentifer = "UserCell"
    private var users = [UserModel.ViewModel.User]()
    private var filteredUsers = [UserModel.ViewModel.User]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var inSearchMode:Bool{
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    var intractor:SearchBusinessLogic!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        configureSearchController()
        intractor.fetchUsers()
    }
    
    func setup(){
        
        let intractor = SearchIntractor()
        let presenter = SearchPresenter()
        
        intractor.presenter = presenter
        self.intractor = intractor
        presenter.viewcontroller = self
        
        intractor.fetchUsers()
        
    }
    func layout(){
        view.backgroundColor = .white
        tableView.register(UsersCell.self, forCellReuseIdentifier: reuseIdentifer)
        tableView.rowHeight = 64
    }
    
    func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        
    }
    
  
}


//MARK: UITableViewDataSource
extension SearchController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count :  users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! UsersCell

        cell.user = SearchModel.ViewModel.UsersCellViewmodel(user: inSearchMode ?  filteredUsers[indexPath.row] : users[indexPath.row])
        
        return cell
    }
}

//MARK: UITableViewDelegate

extension SearchController{
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = ProfileViewController(user: users[indexPath.row])
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension SearchController:SearchDisplayLogic{
    func updateUsers(users: [UserModel.ViewModel.User]) {
        self.users = users
        tableView.reloadData()
    }
    
}

extension SearchController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(){
            filteredUsers = users.filter({ $0.username.lowercased().contains(searchText) || $0.fullname.lowercased().contains(searchText)
            })
        }
        tableView.reloadData()
    }
    
}

