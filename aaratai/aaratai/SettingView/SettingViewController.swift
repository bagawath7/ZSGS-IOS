//
//  SettingViewController.swift
//  aaratai
//
//  Created by zs-mac-4 on 17/10/22.
//

import UIKit
import MobileCoreServices
class SettingViewController: UIViewController{
    let items:[[String]]=[["Mentions","Starred Messages","Contacts","Linked Devices"],
                              ["Accounts","Chats","Notifications and Sounds","security and Privacy","Data and Storage"],["Siri shortcuts"],["About Us","Feedback","Invite Friends"]]
    @IBOutlet weak var settingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let settingnib = UINib(nibName: "SettingTableViewCell", bundle: nil )
        settingTableView.register(settingnib, forCellReuseIdentifier: "settingcell")
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.rowHeight = 75
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func ImagePressed(_ sender: UIButton) {
        actionsheet()
        
    }
    func actionsheet(){
        let alert = UIAlertController(title: "Choose the Photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Open Camera", style: .default,handler: {(handler) in
            self.openCamera()
            
        }))
        alert.addAction(UIAlertAction(title: "Open Gallery", style: .default,handler: {(handler) in
            self.openGallery()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Open Camera", style: .default,handler: {(handler) in
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let image = UIImagePickerController()
            image.allowsEditing = true
            image.sourceType = .camera
            image.mediaTypes = [kUTTypeImage as String]
            self.present(image, animated: true,completion: nil)
        }
    }
    
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let image = UIImagePickerController()
            image.allowsEditing = true
            image.delegate = self
            self.present(image, animated: true,completion: nil)
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingcell", for: indexPath)as!SettingTableViewCell
        
        cell.contentLabel.text = items[indexPath.section][indexPath.row]
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
  
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 1.0
//    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//       let vw = UIView()
//        vw.frame = CGRect(x: 0, y: 0, width: 300, height: 4)
//       vw.backgroundColor = UIColor.red
//
//       return vw
//   }
//   
   
}
extension SettingViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
