//
//  ViewController.swift
//  CarAPI
//
//  Created by zs-mac-4 on 20/10/22.
//

import UIKit


protocol HomeDisplayLogic : AnyObject{
 
}

class HomeViewController: UIViewController ,HomeDisplayLogic{
    
    
    let gradeTextField = makeTextField(withPlaceholderText: "Enter Something")
    let gradePickerValues = ["5. Klasse", "6. Klasse", "7. Klasse"]
    
    var gradePicker: UIPickerView!
    
    let types = [
        "SUV","Convertible","Pickup","Van/Minivan","Wagon","Sedan","Coupe","Hatchback"]
    
    var intractor: HomeBusinessLogic!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        style()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    
    
    
    func setup(){
        let intractor = HomeIntractor()
        let presenter = HomePresenter()
        intractor.presenter = presenter
        presenter.viewController = self
        self.intractor = intractor
        gradePicker = UIPickerView()
        
        gradePicker.dataSource = self
        gradePicker.delegate = self
        
        gradeTextField.inputView = gradePicker
        gradeTextField.text = gradePickerValues[0]
    }
    
    
    
    
    func layout(){
        view.addSubview(gradeTextField)
        
       
    }
    
    
    
    
    
    
    func style(){
        NSLayoutConstraint.activate([gradeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     gradeTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                    ])
        
        
        
        
        
    }
    
}


extension HomeViewController:UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gradeTextField.text = gradePickerValues[row]
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return types[row]
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return gradePickerValues.count
    }


   
}
