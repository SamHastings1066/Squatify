//
//  SceneDelegate.swift
//  Squat Counter
//
//  Created by sam hastings on 08/07/2023.
//

import UIKit
import HorizonCalendar
import AVFoundation

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UITabBarControllerDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        // Allow audio from my app's audio session to mix with audio from active sessions in other audio apps.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }

        // Set the global appearance for all UINavigationBars
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .orange
        // Prevent the navigation bar from changing appearance on scroll
        UINavigationBar.appearance().isTranslucent = false
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: UIScreen.main.bounds)
//
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//
////        let window = UIWindow(windowScene: windowScene)
////
////        self.window = window
//        window = UIWindow(windowScene: windowScene)
//
        let isFirstTime: Bool
        if UserDefaults.standard.object(forKey: "hasOpenedBefore") == nil {
            isFirstTime = true
            UserDefaults.standard.set(true, forKey: "hasOpenedBefore")
            UserDefaults.standard.synchronize()
        } else {
            isFirstTime = false
        }

        if isFirstTime {
            let onboardingVC = OnboardingVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            let navigationController = UINavigationController(rootViewController: onboardingVC)
            window?.rootViewController = navigationController
        } else {
            window?.rootViewController = setupMainTabBarController()
        }


        
        
        
        
        
        //window?.rootViewController = setupMainTabBarController()
        

        
        
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
        
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
    
    func setupMainTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.view.backgroundColor = .black // <-- THIS LINE. THIS LINE!!!!! Means that the tab bar icons are now responsive.
        // Possibly because sometimes, explicitly setting properties like background color can have the side effect of prompting certain parts of the UI to complete their view drawing lifecycle more predictably. This might lead to more consistent layout and presentation, indirectly resolving issues.

        // Set up CalendarNC with CalendarVC
        //let calendarVC = CalendarDisplayVC()
        let calendarVC = CalendarDisplayVC(monthsLayout: .vertical(options: VerticalMonthsLayoutOptions(pinDaysOfWeekToTop: false)))
        let calendarNC = UINavigationController(rootViewController: calendarVC)
        calendarNC.tabBarItem = UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 0)

        // Set up SquatsNC
        let startWorkoutTV = StartWorkoutTV()
        let squatsNC = UINavigationController(rootViewController: startWorkoutTV)
        squatsNC.tabBarItem = UITabBarItem(title: "Squats", image: UIImage(systemName: "dumbbell.fill"), tag: 1)
        
        //tabBarController.viewControllers = [calendarNC, squatsNC]
        tabBarController.setViewControllers([calendarNC, squatsNC], animated: false)
        tabBarController.tabBar.barTintColor = .black
        tabBarController.tabBar.tintColor = .orange
        tabBarController.tabBar.isTranslucent = false
        
        tabBarController.delegate = self

        return tabBarController
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selected \(viewController.description)")
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Here you can put any logic you want to decide if a tab should be selectable or not
        // In this example, we're simply allowing all tabs to be selected
        return true
    }



}

