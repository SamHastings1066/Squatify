//
//  DaySummaryVC.swift
//  Squat Counter
//
//  Created by sam hastings on 26/07/2023.
//

import UIKit
import RealmSwift

class DaySummaryVC: UIViewController {
    
    var filteredWorkouts: Results<RealmWorkout>?
    var dateSelected: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dateSelected!)

        // Do any additional setup after loading the view.
    }
    

}
