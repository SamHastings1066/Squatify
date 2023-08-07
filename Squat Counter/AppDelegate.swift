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
        
        let config = Realm.Configuration(
          schemaVersion: 1, // Increment this number as needed
          migrationBlock: { migration, oldSchemaVersion in
            // Check if we need to apply this migration
            if (oldSchemaVersion < 1) {
              migration.enumerateObjects(ofType: RealmSet.className()) { oldObject, newObject in
                // Apply the default value for hasBeenEditted
                newObject?["hasBeenEditted"] = false
              }
            }
          })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        
        
//        let dummyData = DummyModel()
//        dummyData.name = "Sam"
//        dummyData.age = 38
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
//        do {
//            let realm = try Realm()
//        } catch {
//            print("Error initialising new Realm \(error)")
//        }
        
//        // to delete all objects in the RealmRep class from my Realm database
//        do {
//            let realm = try Realm()
//            try realm.write{
//                let allRealmRepModels = realm.objects(RealmRep.self)
//                realm.delete(allRealmRepModels)
//            }
//        } catch {
//            print("Error initialising new Realm \(error)")
//        }
        
//        // to completely wipe my Realm database, delete the Realm file:
//        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
//        do {
//            try FileManager.default.removeItem(at: realmURL)
//        } catch {
//            print("Unable to delete Realm file: \(error.localizedDescription)")
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

