//
//  SceneDelegate.swift
//  OrderHero
//
//  Created by delivery LAB on 2021/10/14.
//

import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
  
    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        //앱이 running 중이 아닐 때, 외부 딥링크 수신
        let viewController = window!.rootViewController as! ViewController
        if let url = connectionOptions.urlContexts.first?.url {
            print("DeepLinkURL = \(url)")
            if(url.host != nil) {
            viewController.isThereLinkURL = true
            viewController.linkURL = URL(string: "https://"+url.host!+url.path)
            }
        }
   
    }
    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    //앱 running시, 외부 딥링크 수신
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
       // let storyboard = UIStoryboard(name: "Main", bundle: nil)
       // let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        let viewController = window!.rootViewController as! ViewController
        if let url = URLContexts.first?.url {
            print("DeepLinkURL = \(url)")
            if(url.host != nil) {
            viewController.isThereLinkURL = true
            viewController.linkURL = URL(string: "https://"+url.host!+url.path)
            viewController.mainWebView.reload()
            }
                
        }
    }

}

