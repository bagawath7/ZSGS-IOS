//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.`
//

import UIKit
//apikey=a519e74174c64a4d150fce9b24bc2a48
//https://api.openweathermap.org/data/2.5/weather?q={city name}&appid={API key}
class ViewController: UIViewController {

    @IBOutlet weak var SearchTextField: UITextField!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    var weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchTextField.delegate = self
        weatherManager.delegate = self
        weatherManager.fetchWeather(cityName: "Chennai")
       
       
        
        // Do any additional setup after loading the view.
    }

    @IBAction func searchpressed(_ sender: UIButton) {
        SearchTextField.endEditing(true)// to dismiss Keyboard
       
    }
    
}

extension ViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(SearchTextField.text!)
        SearchTextField.endEditing(true)
      
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = SearchTextField.text{
            weatherManager.fetchWeather(cityName: city)
        }
        SearchTextField.text = ""
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }
        else{
            textField.placeholder = "Type  Something"
            return false
        }
    }
}
extension ViewController:WeatherManagerDelegate{
    func didupdateWeather(_ weatherManager:WeatherManager,weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.stringTemperture
            self.cityLabel.text = weather.CityName
            self.conditionImageView.image = UIImage(systemName: weather.condtionName)
        }
        
    }
}
