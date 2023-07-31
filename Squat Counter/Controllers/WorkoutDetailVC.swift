//
//  DayDetailVC.swift
//  Squat Counter
//
//  Created by sam hastings on 28/07/2023.
//

import UIKit
import RealmSwift

class WorkoutDetailVC: UIViewController {
    
    var selectedWorkout: RealmWorkout?
    //var selectedWorkoutID: String?

    @IBOutlet weak var workoutTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutTableView.dataSource = self
//        print(selectedWorkout?.workoutId)
//        print(selectedWorkout?.sets.count ?? 0)
    }
    


}

//MARK: - Extensions

extension WorkoutDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWorkout?.sets.count ?? 0  // number of sets
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if let currentSet = selectedWorkout?.sets[indexPath.row] {
            content.text = "\(currentSet.numReps) x \(currentSet.weight) \(currentSet.exerciseName ?? "no exercise")s"
            content.image = UIImage(systemName: "dumbbell")
            // Customize appearance.
            content.imageProperties.tintColor = .orange
            content.textProperties.color = .white
        }
        cell.contentConfiguration = content
        return cell
    }
    
    
}
