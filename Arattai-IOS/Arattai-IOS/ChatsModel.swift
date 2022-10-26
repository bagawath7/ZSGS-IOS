//
//  ChatsModel.swift
//  Aaratai_Clone
//
//  Created by zs-mac-4 on 21/10/22.
//

import Foundation

struct ChatsModel{
    
    struct FetchResponse{
        struct UserData{
            var data : Data
        }
        
    }
    
    
    struct ViewModel {
        
        
        struct User{
            let userName : String
            let lastmessage : String
            let noOfUnreadMessages: Int
        }
        var users : [User]!
    }
    
    
}
