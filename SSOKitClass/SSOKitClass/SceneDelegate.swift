//
//  SceneDelegate.swift
//  SSOKitClass
//
//  Created by zs-mac-4 on 08/11/22.
//

import UIKit
import SSOKit
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        
        let cliendid = "1002.RK2QRS1QSFIB699745HB7CMYTF3WBL" //zoho workdrive
        let scopes = ["TeamDrive.files.All",
                      "TeamDrive.workspace.All"]
       
        
        let urlscheme = "ZohoTeamDrive"
      
        
        ZSSOKit.initWithClientID(cliendid, scope: scopes, urlScheme: urlscheme, mainWindow: window, buildType: .Live_SSO)
        
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        ZSSOKit.handle(URLContexts.first?.url,
                       sourceApplication: URLContexts.first?.options.sourceApplication,
                       annotation:  URLContexts.first?.options.annotation)
        
    }
    
    


}

