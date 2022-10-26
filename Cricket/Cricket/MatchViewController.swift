//
//  MatchViewController.swift
//  Cricket
//
//  Created by zs-mac-4 on 06/10/22.
//

import UIKit

class MatchViewController: UIViewController {
    var Result:String?
    @IBOutlet weak var InningsLabel: UILabel!

    @IBOutlet weak var TeamNameLabel: UILabel!
    
    @IBOutlet weak var strikerNameLabel: UILabel!
    @IBOutlet weak var nonstrikerNameLabel: UILabel!
    @IBOutlet weak var strikerFourLabel: UILabel!
    @IBOutlet weak var strikerSixLabel: UILabel!
    @IBOutlet weak var strikerBallsLabel: UILabel!
    @IBOutlet weak var strikerStrikeRateLabel: UILabel!
    @IBOutlet weak var nonStrikerRunLabel: UILabel!
    @IBOutlet weak var nonstrikerFourLabel: UILabel!
    @IBOutlet weak var nonstrikerSixLabel: UILabel!
    @IBOutlet weak var nonstrikerballsLabel: UILabel!
    @IBOutlet weak var nonstrikerStrikeRateLabel: UILabel!
    @IBOutlet weak var strikerRunLabel: UILabel!
    @IBOutlet weak var ScoreTextLabel: UILabel!
    @IBOutlet weak var BowlerName: UILabel!
    @IBOutlet weak var BowlwerOvers: UILabel!
    @IBOutlet weak var Bowlermaiden: UILabel!
    @IBOutlet weak var BowlerRuns: UILabel!
    @IBOutlet weak var BowlerWickets: UILabel!
    @IBOutlet weak var BowlerER: UILabel!
    @IBOutlet weak var targetScore: UILabel!
    @IBOutlet weak var Target: UILabel!
    var match = Match(over: 2)
    var team: Team!
    var nextBatsman: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        match.delegate = self
        match.start()


        // Do any additional setup after loading the view.
    }
    
    @IBAction func getInpiut(_ sender: UIButton) {
        match.updateScore(input: sender.tag)
    }
    func displayResult(resultString:String){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let resultvc = sb.instantiateViewController(withIdentifier: "result") as! ResultViewController
        resultvc.delegate = self
        self.navigationController?.present(resultvc, animated: true)

    }
    
}
extension MatchViewController:matchdelegate {
    func result(result: String) {
    Result = result
       displayResult(resultString: result)
       match = Match(over: 2)
       match.delegate = self
       match.start()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goto" {
            let destinationVC = segue.destination as! SelectPlayerViewController
            destinationVC.delegate = self
        }
       
        
    }
   
    
  
    func getbatsmens(team: Team) {
        self.team = team
        performSegue(withIdentifier: "goto", sender: self)
        
    }
        
    
    
    func getScoreDetails(team: Team,striker:Player,nonStriker:Player,bowler:Player) {
        
        self.InningsLabel.text = "\(match.i+1)st Inn"
        self.TeamNameLabel.text = team.name
        
        if(striker.ballsFaces != 0){
            striker.strikeRate = Double(striker.currentScore) / Double(striker.ballsFaces) * 100.0
        }
        if(bowler.ballsBowled != 0){
            bowler.ER = Double(bowler.runs) / Double(bowler.ballsBowled) * 100.0
        }
        
        self.ScoreTextLabel.text = "\(team.TotalRuns)/\(team.wickets)(\(team.over).\(team.balls))"
        
        self.strikerRunLabel.text = String(striker.currentScore)
        self.strikerNameLabel.text = striker.name
        self.strikerFourLabel.text = String(striker.noOfFour)
        self.strikerSixLabel.text = String(striker.noOfSix)
        self.strikerBallsLabel.text = String(striker.ballsFaces)
        self.strikerStrikeRateLabel.text = String(format: "%0.1f", striker.strikeRate)
        
        self.nonstrikerNameLabel.text = nonStriker.name
        self.nonStrikerRunLabel.text = String(nonStriker.currentScore)
        self.nonstrikerFourLabel.text = String(nonStriker.noOfFour)
        self.nonstrikerSixLabel.text = String(nonStriker.noOfSix)
        self.nonstrikerballsLabel.text = String(nonStriker.ballsFaces)
        self.nonstrikerStrikeRateLabel.text = String(format: "%0.1f", nonStriker.strikeRate)
        
        self.BowlerName.text = String(bowler.name)
        self.BowlwerOvers.text = String(bowler.overBowled)
        self.Bowlermaiden.text = String(bowler.maiden)
        self.BowlerRuns.text = String(bowler.runs)
        self.BowlerWickets.text = String(bowler.currentWicket)
        self.BowlerER.text = String(format: "%0.1f", bowler.ER)
        
    }
    
    
}
    
extension MatchViewController:ResultViewControllerDelegate,ResultDelegate{
    func sendnextBatsman(nextBatsman: Int,index:Int) {
        match.removebatsman(index: index)
        match.changebatsman(nextBatsman: nextBatsman)
    }
    
    func getDetailsFromParent() -> Team? {
        return self.team
    }
    
    func getFromParent() -> String {
        return self.Result!
    }
    
    
}
    

