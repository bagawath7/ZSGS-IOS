//
//  ViewController.swift
//  ApiCricket
//
//  Created by zs-mac-4 on 12/10/22.
//

import UIKit

class ViewController: UIViewController {
    var teams = [Team]()
    var collectionView:UICollectionView!
    var currentImage:UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTeam()
        self.setupCollectionView()

        // Do any additional setup after loading the view.
    }
    
    func fetchImage(index:Int,imageId:Int, completion : @escaping((UIImage)->()), failure : @escaping((Error?)->())){
        let headers = [
            "X-RapidAPI-Key": "308a7dbd14mshdb2492bbd18ddeap1038bcjsn03727329bc22",
            "X-RapidAPI-Host": "cricbuzz-cricket.p.rapidapi.com"
        ]
        
        
        let url = "https://cricbuzz-cricket.p.rapidapi.com/img/v1/i1/c\(imageId)/i.jpg?p=de&d=high"
        let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                failure(error!)
            } else {
                if let jd = data{
                    print(jd)
                    self.teams[index].image = data
                    if  let img = UIImage(data: jd){
                        self.currentImage = img
                        DispatchQueue.main.async {
                            completion(img)
                        }
                    }else{
                        failure(nil)
                    }
                }
                else{
                    print("No data")
                }
            }
        })
        
        
        dataTask.resume()
    }
    func  fetchTeam(){
        let headers = [
            "X-RapidAPI-Key": "308a7dbd14mshdb2492bbd18ddeap1038bcjsn03727329bc22",
            "X-RapidAPI-Host": "cricbuzz-cricket.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://cricbuzz-cricket.p.rapidapi.com/teams/v1/international")! as URL,
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
                    self.processData(with: jd)
                }
                else{
                    print("No data")
                }
            }
        })
        
        dataTask.resume()
    }
    func processData(with data : Data){
        
        
        
        if let decodedTeams = try? JSONDecoder().decode(Lists.self, from: data){
            
            
            teams = decodedTeams.list.filter { t in
                return t.teamId != nil
            }
            print(teams)
        }
        else{
            print("Hello")
        }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    func setupCollectionView(){
        
        let screenBounds=UIScreen.main.bounds
        let width=screenBounds.width
        
        
        let flowLayout=UICollectionViewFlowLayout()
        flowLayout.itemSize=CGSize(width: width / 2 - 10, height: width / 2 - 10)
        flowLayout.minimumLineSpacing=15
        
        
        collectionView=UICollectionView(frame: .zero,collectionViewLayout: flowLayout)
        view.addSubview(collectionView)
        collectionView.backgroundColor =  .gray
        
        collectionView.translatesAutoresizingMaskIntoConstraints=false
        
        collectionView.topAnchor.constraint(equalTo: view.topAnchor ,constant:50).isActive=true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 5).isActive=true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor,constant:-5).isActive=true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: 50).isActive=true
        
        let nib=UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        collectionView.delegate=self
        collectionView.dataSource=self
        
    }
    
}

extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        teams.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        as! CollectionViewCell
        
        cell.backgroundColor = .white
        cell.layer.borderWidth=5.0
        cell.layer.cornerRadius=10.0
        cell.layer.borderColor=UIColor.clear.cgColor
        let thisteam=teams[indexPath.row+1]
        
        
        DispatchQueue.main.async {
            
            if let img = thisteam.imageId{
                
                if let idata = thisteam.image{
                    cell.image.image = UIImage(data: idata)
                }else{
                    self.fetchImage(index: indexPath.row, imageId: img) { image in
                        cell.image.image = image
                    } failure: { error in
                        
                    }
                }
            }else{
                cell.image.image = UIImage(named: "hello")
                cell.teamName.text=thisteam.teamName

            }
//
            cell.teamName.text=thisteam.teamName
        }
        
        
        
       
            
        

        
        return cell
    }
}




//filter
//map
//compactmap
//flat
