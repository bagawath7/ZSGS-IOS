//
//  MainTabIntractor.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 08/11/22.
//

import Foundation
import Firebase

protocol MainTabBussinessLogic:AnyObject{
    func fetchuser()
    
}

class MainTabIntractor:MainTabBussinessLogic{
    
    var presenter:MainTabPresentationLogic!
    
    func fetchuser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        COLLECTION_USERS.document(uid).getDocument{ snapshot,error in
            if let snapshot = snapshot {
                self.presenter.presentProfile(response: snapshot)
                
            }
            
            
        }
        
    }
}
