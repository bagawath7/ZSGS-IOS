//
//  ProfileModel.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 09/11/22.
//

import Foundation
import Firebase

struct ProfileModel{
    
    struct FetchResponse{
        struct userdata{
            var snapshot : DocumentSnapshot
        }
    }
    
    
    struct ViewModel {
        
        
        struct HeaderViewmodel{
            let user:UserModel.ViewModel.User
            
            var fullname:String{
                return user.fullname
            }
            var profileImageUrl:URL?{
                return URL(string: user.profileImageUrl)
            }
            
            var followButtonText: String{
                if user.isCurrentUser{
                    return "Edit Profile"
                }
                return user.isFollowed ? "Following" :  "Follow"
                
            }
            var followButtonBackGroundColor : UIColor {
                if !user.isFollowed {
                    return .systemBlue
                }
                return .white
                
            }
            var followButtonTextColor: UIColor{
                if !user.isFollowed {
                    return .white
                }
                return .black
                
            }
            var noOfFollowers: NSAttributedString{
                return StatsTextlabel(value: user.stats.followers, label: "followers")
            }
            var noOfFollowing:NSAttributedString{
                return StatsTextlabel(value: user.stats.following, label: "following")

            }
            
            var noOfPosts:NSAttributedString{
                return StatsTextlabel(value: 7, label: "Posts")
            }
            
            func StatsTextlabel(value: Int,label: String) -> NSAttributedString
            {
                let attributedText = NSMutableAttributedString(string: "\(value)\n",attributes: [.font:UIFont.boldSystemFont(ofSize: 14)])
            
                attributedText.append(NSMutableAttributedString(string: label,attributes: [.font:UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
                                      
                return attributedText
                                      
                  
                    
            }
            
            }
        }
    }
    


