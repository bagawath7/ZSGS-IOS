//
//  ProfileHelper.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 10/11/22.
//

import Foundation
import Firebase
typealias FirestoreCompletion = (Error?) ->Void


struct ProfileWorker{
    
    
    static let profileworker = ProfileWorker()
    
    private init(){
        
    }
    func follow(uid: String, completion: @escaping (FirestoreCompletion)) {
        if let currentUid = Auth.auth().currentUser?.uid{
            COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]){_ in
                COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).setData([:],completion: completion)
            }
        }
        
        
    }
    
    func unfollow(uid: String, completion: @escaping (FirestoreCompletion)) {
        
        if let currentUid = Auth.auth().currentUser?.uid{
            COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete{_ in
                COLLECTION_FOLLOWERS.document(uid).collection("user-followers").document(currentUid).delete(completion: completion)
            }
        }
        
    }
    
    func checkIfUserIsFollowed(uid:String,completion:@escaping(Bool)->Void){
        guard let currentUid = Auth.auth().currentUser?.uid else{return}
        
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            guard let isFollowed = snapshot?.exists else{return}
            completion(isFollowed)
        }
    }
    
}
