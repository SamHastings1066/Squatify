//
//  DaySummaryVC.swift
//  Squat Counter
//
//  Created by sam hastings on 26/07/2023.
//

import UIKit
import RealmSwift
import SwipeCellKit

class DaySummaryVC: UIViewController {
    
    var filteredWorkouts: Results<RealmWorkout>?
    var dateSelected: Date?
    let realm = try! Realm()
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var dayTableView: UITableView!
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tell dayTableView to lok for its data source in the DaySummaryVC - specifically the delegate methods in the extension.
        dayTableView.dataSource = self
        dayTableView.delegate = self
        dayTableView.rowHeight = 80.0
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
        let cell = dayTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        var content = UIListContentConfiguration.valueCell()
        // Configure content.
        content.text = "Workout \(indexPath.row + 1)"
        content.secondaryText = "Details"
        content.image = UIImage(systemName: "star")
        // Customize appearance.
        content.imageProperties.tintColor = .orange
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .gray
        
        cell.contentConfiguration = content
        return cell
    }
    
    
    
}

extension DaySummaryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "DayToWorkoutDetail", sender: self)
    }
    
   
    

}

//MARK: - Swipe call delegate methods

extension DaySummaryVC: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let editAction = SwipeAction(style: .default, title: "Edit", handler:{action, indexpath in
            let destinationVC = EditWorkoutVC()
            destinationVC.realmWorkout = self.filteredWorkouts?[indexPath.row]
            self.navigationController?.pushViewController(destinationVC, animated: true)
            tableView.reloadData()
            
            });
        editAction.backgroundColor = .green //UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            
            let alert = UIAlertController(title: "Are you sure you want to delete this workout?", message: "This action cannot be undone", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                if let workoutToDelete = self.filteredWorkouts?[indexPath.row] {
                    do {
                        
                        try self.realm.write {
                            self.realm.delete(workoutToDelete)

                        }
                        tableView.reloadData()
                    } catch {
                        print("Could not delete item \(error)")
                    }
                    
                }
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
                tableView.reloadData()
            }))
            self.present(alert, animated: true, completion: nil)
            
            
        }

        // customize the action appearance
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(named: "delete-icon")
        let configuration = UIImage.SymbolConfiguration(pointSize: 30.0, weight: .medium)
        let image = UIImage(systemName: "arrow.counterclockwise.circle.fill", withConfiguration: configuration)
        editAction.image = image
        

        return [deleteAction, editAction]
    }
    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        return options
//    }
}
