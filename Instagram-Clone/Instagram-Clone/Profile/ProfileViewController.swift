//
//  ProfileViewController.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 02/11/22.
//

import UIKit
import FirebaseAuth

protocol ProfileDisplayLogic:AnyObject{
   
}

class ProfileViewController: UICollectionViewController {
    
    var intractor:ProfileBussinessLogic!
    var user: UserModel.ViewModel.User
    
    
      
    
    init(user:UserModel.ViewModel.User){
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        print(self.user)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let cellIdentifier = "ProfileCell"
    private let headerIdentifer = "ProfileHeader"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        checkIfUserIsFollowed()
        fetchUserStats()
       
        
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        navigationController?.view.tintColor = .black
        
    }
    
    func setup(){
        
        let intractor = ProfileIntractor()
        let presenter = ProfilePresenter()
        
        intractor.presenter = presenter 
        self.intractor = intractor
        presenter.viewcontroller = self
        
        
        
//        intractor.fetchuser()

        
    }
    
   func layout(){
       navigationItem.title = user.username
       collectionView.backgroundColor = .white
       collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier )
       collectionView.register(ProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifer)
      
    }
    func checkIfUserIsFollowed(){
        ProfileWorker.profileworker.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats(){
        intractor.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            print(stats)
            self.collectionView.reloadData()
        }
    }
    @objc func logout(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("Error ion sign out")
        }
        checkIfUserIsLoggedIn()
        func checkIfUserIsLoggedIn(){
            if Auth.auth().currentUser == nil{
                DispatchQueue.main.async {
                    let controller = LoginViewController()
                    controller.delegate = self.tabBarController as? MainTabController
                    let nav = UINavigationController(rootViewController: controller)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav,animated: true)
                }
              
            }
        }
    }
   
}

//MARK: UICollectionViewDataSource

extension ProfileViewController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifer, for: indexPath) as! ProfileHeaderCell
            header.viewmodel = ProfileModel.ViewModel.HeaderViewmodel(user: user)
            header.delegate = self
            return header
        }
    }


//MARK:UICollectionViewDelegate

extension ProfileViewController{
    
    
}

//MARK:UICollectionViewDelegateFlowLayout

extension ProfileViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 240)
    }
}


extension ProfileViewController:ProfileDisplayLogic{
   
    
    
}

extension ProfileViewController:ProfileHeaderDelegate{
    func header(_ profileHeader: ProfileHeaderCell, didTapActionButtonFor user: UserModel.ViewModel.User) {
        if user.isCurrentUser{
            print("Edit")
        }
        
        else if user.isFollowed{
            ProfileWorker.profileworker.unfollow(uid: user.uid) { _ in
                self.user.isFollowed = false
                self.fetchUserStats()
            }
        }else{
            ProfileWorker.profileworker.follow(uid: user.uid) { error in
                self.user.isFollowed = true
                self.fetchUserStats()
            }
        }
        
        
        
        
    }
    
    
}
