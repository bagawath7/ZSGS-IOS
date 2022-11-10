//
//  ToDoModel.swift
//  APITesting
//
//  Created by zs-mac-4 on 19/10/22.
//

import Foundation

struct ToDoModel{
    
    struct FetchResponse{
        struct ToDoData{
            var data : Data!
        }
    }
    
    
    struct ViewModel {
        struct ToDo : Decodable{
            let userId : Int
            let id : Int
            let title : String
            let completed : Bool
        }
        var objects : [ToDo]!
    }
    
}
