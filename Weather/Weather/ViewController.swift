//
//  ViewController.swift
//  Weather
//
//  Created by zs-mac-4 on 06/10/22.
//

import UIKit

class WeatherViewController: UIViewController {
    @IBOutlet weak var SearchTextField: UITextField!
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    var weatherManager = WeatherManager()

    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        SearchTextField.delegate = self
        weatherManager.delegate = self
        weatherManager.fetchWeather(cityName: "Chennai")
        // Do any additional setup after loading the view.
    }

    @IBAction func searchpressed(_ sender: UIButton) {
        SearchTextField.endEditing(true)//

    }
    
}
extension WeatherViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
extension WeatherViewController:WeatherManagerDelegate{
    func didupdateWeather(_ weatherManager:WeatherManager,weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.stringTemperture
            self.cityLabel.text = weather.CityName
            self.conditionImageView.image = UIImage(systemName: weather.condtionName)
        }
        
    }
}


