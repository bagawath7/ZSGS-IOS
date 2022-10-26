//
//  ViewController.swift
//  Aaratai_Clone
//
//  Created by zs-mac-4 on 21/10/22.
//

import UIKit


protocol ChatsDisplayLogic:AnyObject{
    
    

}

class ChatsViewController: UIViewController{
    
    
    let chatsTableView = UITableView()
    var intractor: ChatsBusinessLogic!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setup()
        layout()
        style()
        
        
    }
    
    private func setup(){
        
        let intractor = ChatsIntractor()
        let presenter = ChatsPresenter()
        
        intractor.presenter = presenter
        self.intractor = intractor
        presenter.viewcontroller = self
        
    
        setupNavBar()
        setupTableView()
        
        
        
    }
    private func layout(){
        
    //TableView
        
        NSLayoutConstraint.activate([chatsTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     chatsTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     self.view.trailingAnchor.constraint(equalTo: chatsTableView.trailingAnchor),
                                     self.view.bottomAnchor.constraint(equalTo: chatsTableView.bottomAnchor)
                                    ])
        
    }
    private func style(){
        
     //View
        view.backgroundColor = UIColor(named: "Appbackground")
    }
    
    private func setupNavBar(){
        navigationItem.rightBarButtonItems=[
            UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .done, target: self, action: .none),
                    UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .done, target: self, action: .none)
                    ]

                let leftbutton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
                leftbutton.setTitle("Chats", for: .normal)
                leftbutton.titleLabel?.font=UIFont.boldSystemFont(ofSize: 35)
             
                leftbutton.contentHorizontalAlignment = .left
                
                let leftbarbtn = UIBarButtonItem(customView: leftbutton)
                navigationItem.leftBarButtonItem = leftbarbtn
                
                navigationController?.navigationBar.tintColor = .label
    }
    
    private func setupTableView(){
        view.addSubview(chatsTableView)
        chatsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        chatsTableView.register(nib, forCellReuseIdentifier: "cell")
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        
    }

}

extension ChatsViewController:ChatsDisplayLogic{
    
    
}
extension ChatsViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatTableViewCell
        return cell
    }
    
    
}
