//
//  ChatsIntractor.swift
//  Aaratai_Clone
//
//  Created by zs-mac-4 on 21/10/22.
//

import Foundation



protocol ChatsBusinessLogic{
    func fecthdata()
    
}

class ChatsIntractor{
    var presenter:ChatsPresentationLogic!
    
    
    
    
}


extension ChatsIntractor : ChatsBusinessLogic{
    func fecthdata() {
        createDummyData()
        
        
    }
    
    
    
    func createDummyData(){
        
        let userNames = ["Bagawath","Siva","Gopal","Sakthi San","Surya","Rajesh","Jenifer","Bagawath","Siva","Gopal","Sakthi San","Surya","Rajesh","Jenifer","Bagawath","Siva","Gopal","Sakthi San","Surya","Rajesh","Jenifer"]
        var users:[ChatsModel.ViewModel.User] = []
        var count = 0
        for user in userNames{
            let tempUser =  ChatsModel.ViewModel.User(userName: user, lastmessage: "Hello Brother", noOfUnreadMessages: count)
            users.append(tempUser)
            count = count + 1
            
        }
        presenter.presentUsers(user: users)
    }
    
    
}
