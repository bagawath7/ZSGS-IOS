//
//  MessageViewController.swift
//  Arattai-IOS
//
//  Created by zs-mac-4 on 26/10/22.
//

import UIKit

protocol MessageDataSource{
   func getDetailsFromParent() -> String
}

protocol MessageDisplayLogic:AnyObject{
   
    
}

class MessageViewController: UIViewController, MessageDisplayLogic {
    var delegate:MessageDataSource!
    var intractor: MessageBusinessLogic!
    let messageTableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = UIRectEdge.bottom
        extendedLayoutIncludesOpaqueBars = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(delegate.getDetailsFromParent())
        setup()
        layout()
        style()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    private func setup(){
        
        let intractor = MessageIntractor()
        let presenter = MessagePresenter()
        
        intractor.presenter = presenter
        self.intractor = intractor
        presenter.viewcontroller = self
        setupNavBar()
    }
    
    
    private func layout(){
        
        self.view.addSubview(messageTableView)
        
        messageTableView.translatesAutoresizingMaskIntoConstraints = false
        messageTableView.backgroundColor = .white
        messageTableView.dataSource = self
        messageTableView.delegate = self
        let nib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        messageTableView.register(nib, forCellReuseIdentifier: "messageCell")
        
        
        
        NSLayoutConstraint.activate([messageTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     messageTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     self.view.trailingAnchor.constraint(equalTo: messageTableView.trailingAnchor),
                                     self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: messageTableView.bottomAnchor,constant: 50.0)
                                     
                                    ])
        
        
    }
    
    private func style(){
        
    }
    
    private func setupNavBar(){
        navigationItem.rightBarButtonItems=[
            UIBarButtonItem(image: UIImage(systemName: "video"), style: .done, target: self, action: .none),
                    UIBarButtonItem(image: UIImage(systemName: "phone"), style: .done, target: self, action: .none)
                    ]

                let leftbutton = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
                leftbutton.setTitle(delegate.getDetailsFromParent(), for: .normal)
                leftbutton.titleLabel?.font=UIFont.boldSystemFont(ofSize: 35)
             
                leftbutton.contentHorizontalAlignment = .left
                
        
                
                let leftbarbtn = UIBarButtonItem(customView: leftbutton)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: .none),leftbarbtn]
                self.navigationController?.navigationBar.isTranslucent = false;

                navigationController?.navigationBar.tintColor = .label
        
    }
    
}


extension MessageViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageTableViewCell
        if(indexPath.row % 2 == 0){
            cell.messageLabel.translatesAutoresizingMaskIntoConstraints = false
            cell.trailing = cell.messageLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor,constant: 16)
        }
        return cell
    }
    
    
    
}
