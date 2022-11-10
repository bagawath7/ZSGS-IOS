//
//  AuthService.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 02/11/22.
//

import UIKit
import FirebaseAuth
import Firebase

struct AuthCredentials {
    let email:String
    let password:String
    let fullname:String
    let username:String
    let profileImage:UIImage
}

struct AuthService{
    
    static func logUserIn(withEmail email: String, password: String,completion:@escaping (AuthDataResult?,Error?)->Void){
        
        Auth.auth().signIn(withEmail: email, password: password,completion: completion)
    }
    
    static func registerUser(withCredentail credentials: AuthCredentials,completion:@escaping(Error?)->Void){
        ImageUploader.uploadImage(image: credentials.profileImage){
            imageUrl in
            
            Auth.auth().createUser(withEmail: credentials.email,password: credentials.password){ (result,error) in
                if let error = error{
                    print(error.localizedDescription)
                    return
                }
                
                guard let uid = result?.user.uid else{
                    return
                }
                let data :[String:Any] = ["email":credentials.email,
                                          "fullname":credentials.fullname,
                                          "profileImageUrl": imageUrl,
                                          "username":credentials.username,
                                          "Uid":uid]
                COLLECTION_USERS.document(uid).setData(data,completion: completion)
            }
        }
    }
       
    
}
