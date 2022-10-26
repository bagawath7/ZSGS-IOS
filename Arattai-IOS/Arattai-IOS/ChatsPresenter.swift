//
//  CharsPresenter.swift
//  Aaratai_Clone
//
//  Created by zs-mac-4 on 21/10/22.
//

import Foundation

protocol ChatsPresentationLogic{
    func presentUsers(user:[ChatsModel.ViewModel.User])
    
}

class ChatsPresenter{
    
   weak var viewcontroller:ChatsDisplayLogic!
    
    
}


extension ChatsPresenter:ChatsPresentationLogic{
    func presentUsers(user: [ChatsModel.ViewModel.User]) {
        let users = ChatsModel.ViewModel(users: user)
        viewcontroller.update(viewmodel: users)
        
            
    }
    
   
    
    
    
    
}
