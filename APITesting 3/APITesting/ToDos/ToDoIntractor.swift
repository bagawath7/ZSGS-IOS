//
//  ToDoIntractor.swift
//  APITesting
//
//  Created by zs-mac-4 on 19/10/22.
//

import Foundation


protocol ToDoBusinessLogic : AnyObject{
    
    func fetchToDos()
}


class ToDoIntractor : ToDoBusinessLogic{
    
    
    
    var presenter : ToDoPresentationLogic!
    
    
    func fetchToDos() {
        
        let todosAPI = "https://jsonplaceholder.typicode.com/todos"
        let todosURL = URL(string: todosAPI)!
        let todosRequest = URLRequest(url: todosURL)
        let urlsession = URLSession.shared
        let todosDataTask = urlsession.dataTask(with: todosRequest) { jsondata, todosResponse, todosError in
            if let jd = jsondata{
                let response = ToDoModel.FetchResponse.ToDoData(data :jd)
                self.presenter?.presentToDos(response: response)
            }
        }
        todosDataTask.resume()
        
    }
    
        
    
}
