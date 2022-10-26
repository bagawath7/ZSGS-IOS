//
//  APIManager.swift
//  CompletionClosure
//
//  Created by zs-mac-4 on 14/10/22.
//

import Foundation

class APIManager :  NSObject{
    
    
    
    func fetchTodos(completion  : @escaping(([ToDo])->()), failure : @escaping((Error?)->()) ){
        let todosAPI = "https://jsonplaceholder.typicode.com/todos"
        let todosURL = URL(string: todosAPI)!
        let todosRequest = URLRequest(url: todosURL)
        
        let urlsession = URLSession.shared
       
        let todosDataTask = urlsession.dataTask(with: todosRequest) { jsondata, todosResponse, todosError in
            if let jd = jsondata{
                if let decodedTodos = try? JSONDecoder().decode([ToDo].self, from: jd){
                    completion(decodedTodos)
                }else{
                    failure(nil)
                }
            }else{
                failure(todosError ?? nil)
            }
        }
        todosDataTask.resume()
    }

    
    
}
