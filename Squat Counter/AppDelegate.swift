//
//  AppDelegate.swift
//  Squat Counter
//
//  Created by sam hastings on 08/07/2023.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
//        let dummyData = DummyModel()
//        dummyData.name = "Sam"
//        dummyData.age = 38
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do {
            let realm = try Realm()
        } catch {
            print("Error initialising new Realm \(error)")
        }
        
//        do {
//            let realm = try Realm()
//            try realm.write{
//                let allDummyModels = realm.objects(DummyModel.self)
//                realm.delete(allDummyModels)
//            }
//        } catch {
//            print("Error initialising new Realm \(error)")
//        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

