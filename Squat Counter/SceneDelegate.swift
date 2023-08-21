//
//  SceneDelegate.swift
//  Squat Counter
//
//  Created by sam hastings on 08/07/2023.
//

import UIKit
import HorizonCalendar

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Set the global appearance for all UINavigationBars
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .orange
        // Prevent the navigation bar from changing appearance on scroll
        UINavigationBar.appearance().isTranslucent = false
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let tabBarController = UITabBarController()

        // Set up CalendarNC with CalendarVC
        let calendarVC = CalendarDisplayVC(monthsLayout: .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: false))) // come back to this to make it true
        let calendarNC = UINavigationController(rootViewController: calendarVC)
        calendarNC.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 0)
        //calendarNC.isToolbarHidden = true


        // Set up SquatsNC
        //let squatsNC = SquatsNC()
        let startWorkoutTV = StartWorkoutTV()
        
        let squatsNC = UINavigationController(rootViewController: startWorkoutTV)
        squatsNC.tabBarItem = UITabBarItem(title: "Squats", image: UIImage(systemName: "dumbbell.fill"), tag: 1)
        
        tabBarController.viewControllers = [calendarNC, squatsNC]
        tabBarController.tabBar.barTintColor = .black
        tabBarController.tabBar.tintColor = .orange
        tabBarController.tabBar.isTranslucent = false
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        
        self.window = window
        
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


}

