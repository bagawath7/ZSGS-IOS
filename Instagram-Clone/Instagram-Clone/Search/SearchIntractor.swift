//
//  SearchIntractor.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 08/11/22.
//

import Foundation
import Firebase
protocol SearchBusinessLogic:AnyObject{
    func fetchUsers()
}

class SearchIntractor:SearchBusinessLogic{
    func fetchUsers() {
        COLLECTION_USERS.getDocuments { (snapshot, error) in
            if let snapshot = snapshot{
                self.presenter.presentUsers(snapshot: snapshot)
                
            }
        }
    }
    
    
    var presenter:SearchPresentationLogic!
}
