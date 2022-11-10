//
//  MainTabController.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 08/11/22.
//


import UIKit
import Firebase
protocol MainTabDisplayLogic:AnyObject{
    func update(user: UserModel.ViewModel.User)
}
class MainTabController: UITabBarController {
    
    var intractor:MainTabBussinessLogic!
    var user:UserModel.ViewModel.User?{
        didSet{
            if let user = user {
                configureViewControllers(withUser: user)
            }
          
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        checkIfUserIsLoggedIn()
        
    }
    func checkIfUserIsLoggedIn(){
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let controller = LoginViewController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true)
            }
          
        }
    }
    func setup(){
        
        let intractor = MainTabIntractor()
        let presenter = MainTabPresenter()
        
        intractor.presenter = presenter
        self.intractor = intractor
        presenter.viewcontroller = self
        
        intractor.fetchuser()
    }
    func configureViewControllers(withUser user:UserModel.ViewModel.User){
        view.backgroundColor = .white
        self.delegate = self
        tabBar.tintColor = .black
        let layout = UICollectionViewFlowLayout()
        let feed = UINavigationController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: UserfeedViewController(collectionViewLayout: layout))
        let search = UINavigationController(unselectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!, rootViewController: SearchController())
        let imageSelector = UINavigationController(unselectedImage: UIImage(named:  "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!, rootViewController: UIViewController())
        let notifications = UINavigationController(unselectedImage: UIImage(named:"like_unselected" )!, selectedImage: UIImage(named: "like_selected")!, rootViewController: UIViewController())
        let profile = UINavigationController(unselectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController: ProfileViewController(user: user))
        
        viewControllers = [feed,search,imageSelector,notifications,profile]
        
    }
    
 
    
    
}


extension UINavigationController{
    
    
    convenience init(unselectedImage:UIImage,selectedImage:UIImage,rootViewController: UIViewController){
        self.init(rootViewController: rootViewController)
        tabBarItem.image = unselectedImage
        tabBarItem.selectedImage = selectedImage
        navigationBar.tintColor = .black

    }
}



extension MainTabController:MainTabDisplayLogic{
    func update(user: UserModel.ViewModel.User) {
        self.user = user
    }
    
   
    
    
}

extension MainTabController:AuthenticationDelegate{
    func authenticationDidComplete() {
        intractor.fetchuser()
        dismiss(animated: true)
    }
}

extension MainTabController:UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2{
            
        }
    }
    
}
