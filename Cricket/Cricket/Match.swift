//
//  Match.swift
//  Cricket
//
//  Created by zs-mac-4 on 06/10/22.
//

import Foundation
protocol matchdelegate{
     func getScoreDetails(team: Team,striker:Player,nonStriker:Player,bowler:Player)
     func getbatsmens(team:Team)
     func result(result:String)
}
class Match{
    let india:[String]=["Rohit", "KL Rahul", "Virat Kohli", "Suryakumar", "Shreyas Iyer", "Rishabh Pant", "Dinesh Karthik","R. Ashwin", "Y.Chahal", "Axar Patel", "A. Singh"]
      
        
    let southAfrica:[String]=["T.Bavuma", "Q de Kock", "R.Hendricks", "Heinrich Klaasen", "K. Maharaj", "A.Markram", "D.Miller", "L.Ngidi", "A. Nortje", "W.Parnell", "D.Pretorius"]

    var teams:[Team]!
    var prevBall:Int!
    var i:Int = 0
    var bowler = 6;
    let over:Int
    
    var delegate: matchdelegate?
    init(over:Int) {
        self.over = over
        teams = [Team]()
        
        self.teams.append(Team(name: "IND", Players: india))
        self.teams.append(Team(name: "SA", Players: southAfrica))
        
        
    }
    func start(){
        delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
    }
    func result(){
        if(teams[0].TotalRuns > teams[1].TotalRuns){
            delegate?.result(result: "\(teams[0].name) won the Match")
        }
        else{
            delegate?.result(result: "\(teams[1].name) Won the Match")
        }
    }
    func changebatsman(nextBatsman:Int){
        teams[i].Striker = nextBatsman
        delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
    }
    func removebatsman(index:Int){
        self.teams[i].playerIndex.remove(at: index)
    }
    func updateScore(input:Int){
        
        switch input {
        case 1...6:
            teams[i].TotalRuns += input
            teams[i].players[teams[i].Striker].currentScore += input
            teams[i].players[teams[i].Striker].ballsFaces += 1
            teams[(i+1)%2].players[bowler].ballsBowled += 1
            teams[(i+1)%2].players[bowler].runs += input
            teams[(i+1)%2].players[bowler].overRuns += input
            teams[i].balls += 1



            if(input == 4){
                teams[i].players[teams[i].Striker].noOfFour += 1
            }
            if(input == 6){
                teams[i].players[teams[i].Striker].noOfSix += 1
            }
            if(input==1 || input==3){
                let temp =  teams[i].Striker
                teams[i].Striker = teams[i].NonStriker
                teams[i].NonStriker = temp
            }
            delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
            break
        
           
        case -1: teams[i].wickets += 1
            teams[i].balls += 1

            if(teams[i].wickets != 10){
                delegate?.getbatsmens(team: teams[i])
            }else{
                delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
            }
            teams[(i+1)%2].players[bowler].ballsBowled += 1
            teams[(i+1)%2].players[bowler].currentWicket += 1
            

                 
           break
        case -2:
            teams[i].TotalRuns += 1
            teams[(i+1)%2].players[bowler].overRuns += 1
            delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])

        case -3:
            teams[i].TotalRuns += 1
        default:
            teams[i].players[teams[i].Striker].ballsFaces += 1
            teams[(i+1)%2].players[bowler].ballsBowled += 1
            teams[(i+1)%2].players[bowler].runs += input
            teams[(i+1)%2].players[bowler].overRuns += 1
            teams[i].balls += 1
            delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
            

            break
    
        }
        if(teams[i].balls==6){
            teams[(i+1)%2].players[bowler].overBowled += 1
            teams[i].balls = 0
            teams[i].over += 1
            if(teams[(i+1)%2].players[bowler].overRuns == 0){
                teams[(i+1)%2].players[bowler].maiden += 1
            }
            teams[(i+1)%2].players[bowler].overRuns = 0
            bowler = ((teams[i].over)%5)+6;
            let temp =  teams[i].Striker
            teams[i].Striker = teams[i].NonStriker
            teams[i].NonStriker = temp
            delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
        }
        if(i==1 &&  teams[i].TotalRuns > teams[i-1].TotalRuns ){
            result( )
        }
        else{
            if(teams[i].over == self.over || teams[i].wickets == 10){
                if(i==0){
                    i = i+1
                    delegate?.getScoreDetails(team: teams[i],striker: teams[i].players[teams[i].Striker],nonStriker: teams[i].players[teams[i].NonStriker],bowler:teams[(i+1)%2].players[bowler])
                    
                }else{
                    result()
                }
                
            }
                
            
        }
       

            
        }
        

        
    }

