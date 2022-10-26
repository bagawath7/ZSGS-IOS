//
//  SelectPlayrtViewController.swift
//  Cricket
//
//  Created by zs-mac-4 on 08/10/22.
//

import UIKit
protocol ResultViewControllerDelegate{
    func getDetailsFromParent()->Team?
    func sendnextBatsman(nextBatsman:Int,index:Int)
}
class SelectPlayerViewController: UIViewController{
    @IBOutlet weak var PlayersTableview: UITableView!    
    var delegate : ResultViewControllerDelegate?
    var team:Team!
    var players:[Player]!
    var remaining:[Int]!
    var nextBatsman:Int!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTable()
        team = delegate?.getDetailsFromParent()
        players = team.players
        remaining = team.playerIndex
        
        
        
        // Do any additional setup after loading the view.
    }
    func setupTable(){
      
        let nib = UINib(nibName: "PlayerTableViewCell", bundle: nil)
        PlayersTableview.register(nib, forCellReuseIdentifier: "cell")
        PlayersTableview.delegate = self
        PlayersTableview.dataSource = self
        
    }
        
    }
extension SelectPlayerViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remaining.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlayerTableViewCell
     
        cell.PlayerName.text = players[remaining[indexPath.row]].name
        
        return cell
       
        }
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 100
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        nextBatsman =  remaining[indexPath.row]
        delegate?.sendnextBatsman(nextBatsman: nextBatsman,index: indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
    
}
