//
//  ProfileViewModel.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 07/11/22.
//

import Foundation
import Firebase
struct UserModel{
    
    struct FetchResponse{
        struct userdata{
            var snapshot : DocumentSnapshot
        }
    }
    
    
    struct ViewModel {
        struct StatsViewModel{
            let followers: Int
            let following: Int
        }
        struct User{
            let email:String
            let fullname:String
            let username:String
            let profileImageUrl:String
            let uid: String
            
            var isCurrentUser:Bool{
                return Auth.auth().currentUser?.uid == uid
                
            }
            var isFollowed = false
            var stats: StatsViewModel!
            
        }
        
        
        
    }
    
}

extension UserModel.ViewModel.User{
    
    init(dictionary:[String:Any]){
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.uid = dictionary["Uid"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.stats = UserModel.ViewModel.StatsViewModel(followers: 0, following: 0)

    }
}
