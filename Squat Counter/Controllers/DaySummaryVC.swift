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
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var dayTableView: UITableView!
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tell dayTableView to lok for its data source in the DaySummaryVC - specifically the delegate methods in the extension.
        dayTableView.dataSource = self
        dayTableView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DayToWorkoutDetail" ,
            let destinationVC = segue.destination as? WorkoutDetailVC,
                let indexPath = dayTableView.indexPathForSelectedRow {
            destinationVC.selectedWorkout = filteredWorkouts?[indexPath.row]
                }
    }
}


//MARK: - Extensions

extension DaySummaryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWorkouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a cell
        let cell = dayTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        // Configure content.
        content.text = "Workout \(indexPath.row + 1)"
        content.image = UIImage(systemName: "star")
        // Customize appearance.
        content.imageProperties.tintColor = .orange
        content.textProperties.color = .white
        
        cell.contentConfiguration = content
        return cell
    }
    
    
}

extension DaySummaryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DayToWorkoutDetail", sender: self)
    }
}
