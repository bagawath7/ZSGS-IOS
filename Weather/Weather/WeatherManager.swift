//
//  WeatherManager.swift
//  Clima
//
//  Created by zs-mac-4 on 05/10/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
protocol WeatherManagerDelegate{
    func didupdateWeather(_ weatherManager:WeatherManager,weather: WeatherModel)
}
struct WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=a519e74174c64a4d150fce9b24bc2a48&units=metric"
    var delegate: WeatherManagerDelegate?
    func fetchWeather(cityName:String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        print(urlString)
        performRequest(urlString: urlString)
    }
    func performRequest(urlString:String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url){
                (data,response,error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data{
                    if  let weather = self.parseJSON(weatherdata: safeData){
                        delegate?.didupdateWeather(self,weather: weather)
                    }
                    
                }
            }
            task.resume()
        }
    }
    func parseJSON(weatherdata: Data)-> WeatherModel?{
        let decoder = JSONDecoder()
        do{
             let decodedData = try decoder.decode(WeatherData.self,from: weatherdata)
            let name = decodedData.name
            let temp = decodedData.main.temp
            let weatherId = decodedData.weather[0].id
            let weather = WeatherModel(weatherId: weatherId, CityName: name, temperture: temp)
            print(weather.condtionName)
            return weather
        }catch{
            print(error)
            return nil
        }
    }
    
}
