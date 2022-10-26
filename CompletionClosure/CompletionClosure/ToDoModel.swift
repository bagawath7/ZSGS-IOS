//
//  ToDoModel.swift
//  APITesting
//
//  Created by zs-mac-2 on 11/10/22.
//

import Foundation


struct ToDo : Decodable{
    
    let userId : Int
    let id : Int
    let title : String
    let completed : Bool
    
    
}
