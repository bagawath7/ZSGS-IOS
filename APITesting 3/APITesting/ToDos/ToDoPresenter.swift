//
//  ToDoPresenter.swift
//  APITesting
//
//  Created by zs-mac-4 on 19/10/22.
//

import Foundation


protocol ToDoPresentationLogic : AnyObject{
    func presentToDos(response : ToDoModel.FetchResponse.ToDoData!)
}


class ToDoPresenter : ToDoPresentationLogic{
    
    weak var viewcontroller : ToDoDisplayLogic!
    
    func presentToDos(response: ToDoModel.FetchResponse.ToDoData!) {
        if let resp = response, let data = resp.data{
            
            if let decodedTodos = try? JSONDecoder().decode([ToDoModel.ViewModel.ToDo].self, from: data){
                let viewmodel = ToDoModel.ViewModel(objects: decodedTodos)
                DispatchQueue.main.async {
                    self.viewcontroller?.update(viewmodel: viewmodel)
                }
                
                
            }
        }
        
    }
}
