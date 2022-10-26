//
//  ChatViewController.swift
//  aaratai
//
//  Created by zs-mac-4 on 18/10/22.
//

import UIKit

class MessageViewController: UIViewController {
    var messages = [Message]()
    @IBOutlet weak var mikeButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        createDummyMessages()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        view.backgroundColor = .black
        let messagenib = UINib(nibName: "MessageTableViewCell", bundle: nil)
        chatTableView.register(messagenib , forCellReuseIdentifier:
                        MessageTableViewCell.identifier)
        chatTableView.dataSource = self
        chatTableView.delegate = self
        chatTableView.estimatedRowHeight = 50
        bottomView.layer.cornerRadius = 25
        plusButton.layer.cornerRadius = 24
        mikeButton.layer.cornerRadius = 24
        messageTextField.attributedPlaceholder = NSAttributedString(
            string: "Start Typing",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 132/255, green: 132/255, blue: 132/255, alpha: 1.0)]
        )
        

    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    

  

}
extension MessageViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier, for: indexPath) as! MessageTableViewCell
        cell.backgroundColor = .clear
        cell.messageTextField.text = messages[indexPath.row].messages
        cell.senderImage.layer.cornerRadius = 25.0
        
       
        if !messages[indexPath.row].isSender {
            cell.leading.isActive = false
            cell.trailing.isActive = true
            cell.senderImage.isHidden = true
        }else{
           cell.leading.isActive = true
            cell.trailing.isActive = false
            cell.senderImage.isHidden = false
       }

        return cell
        
    }
}


extension MessageViewController{
    func createDummyMessages(){
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Yeah .....I am good...wbu",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))
        messages.append(Message(messages: "Hello How are you?",isSender: true))
        messages.append(Message(messages: "Hello How are you?",isSender: false))



    }
    
    
    
    }
