//
//  ViewController.swift
//  aaratai
//
//  Created by zs-mac-4 on 17/10/22.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "ChatTableViewCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = 70
        tableView?.backgroundColor = .clear
        // Do any additional setup after loading the view.
    }
 

}
extension ChatViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ChatTableViewCell
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "message")
//        vc.isModalInPresentation = true
        self.navigationController?.pushViewController(vc, animated: false)
        vc.modalPresentationStyle = .fullScreen
    }
    
    
    
}

