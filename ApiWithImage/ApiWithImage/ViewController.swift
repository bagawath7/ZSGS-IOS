//
//  ViewController.swift
//  ApiWithImage
//
//  Created by zs-mac-4 on 12/10/22.
//

import UIKit

class ViewController: UIViewController {
    var image:UIImageView?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
        image = UIImageView()
        image?.frame = CGRect(x: 40, y: 40, width: 100, height: 100)
        image?.backgroundColor = .black
        view.addSubview(image!)
        // Do any additional setup after loading the view.
    }
    func fetchImage(){
        let headers = [
            "X-RapidAPI-Key": "92c4210aacmshd23a0f0fbc85d00p1da4e1jsn0c60826a48c2",
            "X-RapidAPI-Host": "cricbuzz-cricket.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://cricbuzz-cricket.p.rapidapi.com/img/v1/i1/c170661/i.jpg?p=de&d=high")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                if let jd = data{
                    print(jd)
                    
                    self.image?.image = UIImage(data: jd)
                   
                }
                else{
                    print("No data")
                }
            }
        })
        
        
        dataTask.resume()
        
    }
    func processData(with data : Data){
        
        
        
//        if let decodedTeams = try? JSONDecoder().decode(, from: data){
//            let teams = decodedTeams.list
//            print(teams)
//        }
//        else{
//            print("Hello")
//        }
        
    }
}

