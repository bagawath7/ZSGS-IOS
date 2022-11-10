//
//  SearchModel.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 09/11/22.
//

import Foundation
import Foundation
import Firebase

struct SearchModel{
    
    struct FetchResponse{
        struct Usersdata{
            var snapshot : QuerySnapshot
        }
    }
    
    
    struct ViewModel {
       
        
        struct UsersCellViewmodel{
            let user:UserModel.ViewModel.User
            
            var username:String{
                return user.username
            }
            
            var fullname:String{
                return user.fullname
            }
            var profileImageUrl:URL?{
                return URL(string: user.profileImageUrl)
            }
        }
    }
    
}
