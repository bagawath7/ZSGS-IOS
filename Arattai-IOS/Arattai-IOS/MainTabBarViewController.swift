//
//  MainTabBarViewController.swift
//  Aratai Clone
//
//  Created by zs-mac-2 on 21/10/22.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.view.backgroundColor = .systemBackground
        let storiesVC=UINavigationController(rootViewController: UIViewController())
        let chatsVC=UINavigationController(rootViewController: ChatsViewController())
        let settingVC=UINavigationController(rootViewController: UIViewController())
        
        storiesVC.title="Stories"
        chatsVC.title="Chats"
        settingVC.title="Settings"
        
        storiesVC.tabBarItem.tag=0
        chatsVC.tabBarItem.tag=1
        settingVC.tabBarItem.tag=2
        
    
        
        
        storiesVC.tabBarItem.image=UIImage(named:"reel")
        chatsVC.tabBarItem.image=UIImage(systemName: "ellipsis.message")
        settingVC.tabBarItem.image=UIImage(systemName: "gearshape.fill")
        

        tabBar.tintColor = UIColor(red: 0.38, green: 0.46, blue: 0.87, alpha: 1.0)
        tabBar.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 1.0)
        tabBar.isTranslucent = false;
        viewControllers = [storiesVC,chatsVC,settingVC]
       

        selectedIndex = 1
        
        
    }
    

    

}
