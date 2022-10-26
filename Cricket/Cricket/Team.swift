//
//  Team.swift
//  Cricket
//
//  Created by zs-mac-4 on 03/10/22.
//

import Foundation
class Team{
    let name:String
    var TotalRuns: Int
    var wickets:Int
    var over:Int
    var balls:Int
    var Striker:Int
    var NonStriker:Int
    var players:[Player]
    var playerIndex:[Int]
    init(name: String!,Players:[String]) {
        self.name = name
        self.players = [Player]()
        self.balls = 0
        self.wickets = 0
        self.balls = 0
        self.over = 0
        self.TotalRuns = 0
        self.Striker = 0
        self.NonStriker = 1
        playerIndex = [2,3,4,5,6,7,8,9,10]
        for i in 0...10{
            let player = Player(name: Players[i])
            self.players.append(player)
        }
        self.fetchTodos()

        
        
    }
    func fetchTodos(){
        
        let headers = [
            "X-RapidAPI-Key": "92c4210aacmshd23a0f0fbc85d00p1da4e1jsn0c60826a48c2",
            "X-RapidAPI-Host": "cricket-live-data.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://cricket-live-data.p.rapidapi.com/fixtures-by-series/606")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse as Any)
            }
        })

        dataTask.resume()
        
    }
}
