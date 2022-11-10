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
   
    func displayMessages(viewmodel:[[ChatMessage]])
    
}

class MessageViewController: UIViewController, MessageDisplayLogic {
    func displayMessages(viewmodel: [[ChatMessage]]) {
        self.viewmodel = viewmodel
    }
    
    
  
    let cellId = "id123"
    var delegate:MessageDataSource!
    var intractor: MessageBusinessLogic!
    
    lazy var messageTableView:UITableView = {
        let tableView =  UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .black.withAlphaComponent(0.5)
        tableView.allowsSelection = false

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        
       return tableView
    }()
    
    let plusButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName:"plus.circle") , for: .normal)
        button.tintColor =  UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 1.0)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 45, left: 45, bottom: 45, right: 45)


        
        return button
    }()
    
    let typingTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Start Typing",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 132/255, green: 132/255, blue: 132/255, alpha: 1.0)]
        )
        return tf
            
    }()
    let stickerButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "sticker") , for: .normal)
        button.tintColor = UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 1.0)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top:75, left: 75, bottom: 75, right: 75)


        return button
    }()
    let micButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName:"mic.fill") , for: .normal)
        button.tintColor =  UIColor(red: 86/255, green: 105/255, blue: 197/255, alpha: 1.0)
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 45, left: 45, bottom: 45, right: 45)


        return button
    }()
    
    
    var viewmodel:[[ChatMessage]] = [[]]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        edgesForExtendedLayout = UIRectEdge.bottom
        extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(delegate.getDetailsFromParent())
        setup()
        setupNavBar()
        layout()
        intractor.fetch()

    }
    
    
    private func setup(){
        
        let intractor = MessageIntractor()
        let presenter = MessagePresenter()
        
        intractor.presenter = presenter
        self.intractor = intractor
        presenter.viewcontroller = self
      
    }
    
    
    private func setupNavBar(){
        navigationItem.rightBarButtonItems=[
            UIBarButtonItem(image: UIImage(systemName: "video"), style: .done, target: self, action: .none),
                    UIBarButtonItem(image: UIImage(systemName: "phone"), style: .done, target: self, action: .none)
                    ]
        let leftbutton = CustomButton(title: delegate.getDetailsFromParent(), subtitle: "Online")
        leftbutton.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        leftbutton.contentHorizontalAlignment = .left
                
        
                
                let leftbarbtn = UIBarButtonItem(customView: leftbutton)
        navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: .none),leftbarbtn]
                self.navigationController?.navigationBar.isTranslucent = false;

                navigationController?.navigationBar.tintColor = .label
        
    }
    
    
    private func layout(){
        
        self.view.addSubview(messageTableView)
        
        NSLayoutConstraint.activate([messageTableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                                     messageTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                                     self.view.trailingAnchor.constraint(equalTo: messageTableView.trailingAnchor),
                                     self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: messageTableView.bottomAnchor,constant: 60.0)
                                     
                                    ])
        
        
         
    }
    
   
    
}


extension MessageViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewmodel[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewmodel.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = viewmodel[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormatter.string(from: firstMessageInSection.date)
            
            let label = DateHeaderLabel()
            label.text = dateString
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.backgroundColor = .black
            
            let containerView = UIView()
            
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            return containerView
            
        }
        return nil
    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatMessageCell
        let chatMessage = viewmodel[indexPath.section][indexPath.row]
        cell.chatMessage = chatMessage
        return cell
    }


}

    
    
class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        textColor = .white
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
}
    
    
class CustomButton: UIButton {

    required init(title: String, subtitle: String) {
        super.init(frame: CGRect.zero)

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byWordWrapping

        let titleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20),
        ]
        let subtitleAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
        ]

        let attributedString = NSMutableAttributedString(string: title, attributes: titleAttributes)
        attributedString.append(NSAttributedString(string: "\n"))
        attributedString.append(NSAttributedString(string: subtitle, attributes: subtitleAttributes))

        setAttributedTitle(attributedString, for: UIControl.State.normal)
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
