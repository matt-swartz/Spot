//
//  SceneDelegate.swift
//  Spot
//
//  Created by Jin Kim on 10/17/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // It is crucial that we adjust the root, to ensure that we are not eating up RAM through the hierarchy
        window = UIWindow(windowScene: windowScene)
        var storyboard = UIStoryboard(name: "NewUser", bundle: nil)
        
        let defaults = UserDefaults.standard
        
        // If user is not logged in yet, we want to direct them to where new users should go
        if (defaults.object(forKey: "username") as! String == "") {
            let loginController = storyboard.instantiateViewController(identifier: "StartScreen")
            
            window?.rootViewController = loginController
            window?.makeKeyAndVisible()
        // User is already logged in -> But needs to complete training
        } else if (defaults.object(forKey: "completedTraining") as! Bool == false) {
            storyboard = UIStoryboard(name: "Training", bundle: nil)
            
            let trainingController = storyboard.instantiateViewController(identifier: "TrainingScreen")
            
            window?.rootViewController = trainingController
            window?.makeKeyAndVisible()
        // User is already logged in -> Redirect to main storyboard
        } else {
            storyboard = UIStoryboard(name: "Main", bundle: nil) // If the user is logged in, we want to go to the main board
            
            let mainController = storyboard.instantiateViewController(identifier: "MainScreen")
            
            window?.rootViewController = mainController
            window?.makeKeyAndVisible()
        }
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

