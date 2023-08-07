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
        workoutTableView.rowHeight = 80.0

    }
    


}

//MARK: - Extensions

extension WorkoutDetailVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedWorkout?.sets.count ?? 0  // number of sets
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        //var content = cell.defaultContentConfiguration()
        var content = UIListContentConfiguration.valueCell()
        var weightString: String?
        if let currentSet = selectedWorkout?.sets[indexPath.row] {
            if currentSet.weightLbs != 0 {
                weightString = "\(currentSet.weightLbs)lbs"
            }
            content.text = "\(currentSet.numReps) x \(weightString ?? "bodyweight") \(currentSet.exerciseName ?? "no exercise")s"
            content.secondaryText = "Details"
            content.image = UIImage(systemName: "dumbbell")
            // Customize appearance.
            content.imageProperties.tintColor = .orange
            content.textProperties.color = .white
            content.secondaryTextProperties.color = .gray
        }
        cell.contentConfiguration = content
        return cell
    }
    
    
}
