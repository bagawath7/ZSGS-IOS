//
//  WeatherModel.swift
//  Clima
//
//  Created by zs-mac-4 on 05/10/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
struct WeatherModel {
    let weatherId:Int
    let CityName:String
    let temperture:Double
    var stringTemperture: String {
        return String(format: "%.1f", temperture)
    }
    
    var condtionName: String{
        switch weatherId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
}
