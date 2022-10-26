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
            var data : Data!
        }
        
    }
    
    
    struct ViewModel {
        
        
        struct User{
            
            struct Message{
                let text : String
                let isSender : Bool
            }
            let userName : Int
            let userImage : Int
            let messages : [Message]
            let noOfUnreadMessages: Int
            let completed : Bool
        }
        var users : [User]!
    }
    
    
}
