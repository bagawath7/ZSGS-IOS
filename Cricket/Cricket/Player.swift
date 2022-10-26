//
//  Player.swift
//  Cricket
//
//  Created by zs-mac-4 on 03/10/22.
//

class Player{
    let name:String
    var currentScore:Int
    var strikeRate:Double = 0.0
    var noOfFour:Int
    var noOfSix:Int
    var currentWicket:Int
    var runs:Int
    var overBowled:Int
    var ballsFaces:Int
    var ballsBowled:Int
    var ER:Double = 0.0
    var overRuns:Int
    var maiden:Int = 0 
    init(name:String){
        self.name = name
        currentScore = 0
        strikeRate = 0
        noOfFour = 0
        noOfSix = 0
        currentWicket = 0
        runs = 0
        ballsFaces = 0
        ballsBowled = 0
        overBowled = 0
        overRuns = 0 
    }
}
