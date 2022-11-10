//
//  MainTabPresenter.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 08/11/22.
//

import Foundation
import Firebase

protocol MainTabPresentationLogic:AnyObject{
    func presentProfile(response: DocumentSnapshot)
    
}

class MainTabPresenter:MainTabPresentationLogic{
    
    weak var viewcontroller:MainTabDisplayLogic!
    func presentProfile(response: DocumentSnapshot) {
        if let dictionary = response.data(){
            let user = UserModel.ViewModel.User(dictionary: dictionary)
            print(user)
            DispatchQueue.main.async {
                self.viewcontroller.update(user: user)
            }
        }
    }
}
