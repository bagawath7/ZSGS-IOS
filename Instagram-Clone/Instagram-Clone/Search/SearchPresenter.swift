//
//  SearchPresenter.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 08/11/22.
//

import Foundation
import Firebase
protocol SearchPresentationLogic:AnyObject{
   func presentUsers(snapshot: QuerySnapshot)
    
}

class SearchPresenter:SearchPresentationLogic{
    func presentUsers(snapshot: QuerySnapshot) {
        let users = snapshot.documents.map { UserModel.ViewModel.User(dictionary: $0.data())}
        viewcontroller.updateUsers(users: users)
        
    }
    
  
    
    
   weak var viewcontroller:SearchDisplayLogic!
    
}
