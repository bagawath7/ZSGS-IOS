//
//  File.swift
//  ApiCricket
//
//  Created by zs-mac-4 on 12/10/22.
//

import Foundation
import UIKit
struct Lists:Codable{
    let list:[Team]
}

struct Team:Codable{
    let teamName:String
    let teamSName: String?
    let teamId: Int?
    let imageId: Int?
    var image:Data?
    
}
