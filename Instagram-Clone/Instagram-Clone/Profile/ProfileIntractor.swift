//
//  ProfileIntractor.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 07/11/22.
//

import Foundation
import Firebase



protocol ProfileBussinessLogic:AnyObject{
   
    func fetchUserStats(uid:String,completion:@escaping(UserModel.ViewModel.StatsViewModel)->Void)
    
}

class ProfileIntractor:ProfileBussinessLogic{
    
    var presenter:ProfilePresentationLogic!
    
   
    
    func fetchUserStats(uid:String,completion:@escaping(UserModel.ViewModel.StatsViewModel)->Void){
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { (snapshot,_ ) in
            let followers = snapshot?.documents.count ?? 0
            COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { (snapshot,_ ) in
                let following = snapshot?.documents.count ?? 0
                completion(UserModel.ViewModel.StatsViewModel(followers: followers, following: following))
            }
            
            
        }
        
        
        
        
        
        
    }
}
