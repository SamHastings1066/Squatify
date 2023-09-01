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
        view.backgroundColor = .black
        // tell dayTableView to lok for its data source in the DaySummaryVC - specifically the delegate methods in the extension.
        dayTableView.dataSource = self
        dayTableView.delegate = self
        dayTableView.rowHeight = 80.0
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, YYYY"
        
        navigationItem.title = dateFormatter.string(from: dateSelected!)
        
        // Set the title of the back button for the next view controller
        dateFormatter.dateFormat = "MMM d"
        let backButton = UIBarButtonItem()
        backButton.title = dateFormatter.string(from: dateSelected!)
        navigationItem.backBarButtonItem = backButton
        
        // Add the header view with user instructions
        
        let headerLabel = UILabel()
        headerLabel.text = "Swipe a workout to the left to edit or delete it."
        headerLabel.numberOfLines = 0
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15)
        ])
        
        dayTableView.tableHeaderView = headerView
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DayToWorkoutDetail" ,
            let destinationVC = segue.destination as? WorkoutDetailVC,
                let indexPath = dayTableView.indexPathForSelectedRow {
            destinationVC.selectedWorkout = filteredWorkouts?[indexPath.row]
                }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = .black
        dayTableView.reloadData()
    }
}


//MARK: - Extensions

extension DaySummaryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filtered = filteredWorkouts {
            if filtered.count > 0 {
                return (filteredWorkouts?.count)!
            } else {
                return 1
            }
        }
         else {
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a cell
        
        if let filtered = filteredWorkouts {
            if filtered.count > 0 {
                //if (filteredWorkouts?.count)! > 0 {
                let cell = dayTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! SwipeTableViewCell
                cell.delegate = self
                var content = UIListContentConfiguration.valueCell()
                // Configure content.
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                let startTimeString = dateFormatter.string(from: filteredWorkouts?[indexPath.row].startTime ?? Date())
                let endTimeString = dateFormatter.string(from: filteredWorkouts?[indexPath.row].endTime ?? Date())
                content.text = "Workout \(indexPath.row + 1)"
                content.secondaryText = "\(startTimeString) - \(endTimeString)"
                content.image = UIImage(systemName: "star")
                // Customize appearance.
                content.imageProperties.tintColor = .orange
                content.textProperties.color = .white
                content.secondaryTextProperties.color = .gray
                
                cell.contentConfiguration = content
                return cell
            }
            else {
            let cell = dayTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "No workouts recorded."
            content.image = UIImage(systemName: "star")
            // Customize appearance.
            content.imageProperties.tintColor = .orange
            content.textProperties.color = .white
            
            cell.contentConfiguration = content
            return cell
        }
        } else {
            let cell = dayTableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "No workouts recorded."
            content.image = UIImage(systemName: "star")
            // Customize appearance.
            content.imageProperties.tintColor = .orange
            content.textProperties.color = .white
            
            cell.contentConfiguration = content
            return cell
        }
        
    }
    
    
    
}

extension DaySummaryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let filtered = filteredWorkouts {
            if filtered.count > 0 {
                //if (filteredWorkouts?.count)! > 0 {
                self.performSegue(withIdentifier: "DayToWorkoutDetail", sender: self)
            }
            else {
                return
            }
        } else {
            return
        }
        
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
        //deleteAction.image = UIImage(systemName: "trash.fill", withConfiguration: configuration)
        let image = UIImage(systemName: "pencil", withConfiguration: configuration)
        editAction.image = image
        

        return [deleteAction, editAction]
    }
    
}
