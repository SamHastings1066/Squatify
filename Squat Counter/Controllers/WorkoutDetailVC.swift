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
    let realm = try! Realm()
    //var selectedWorkoutID: String?

    @IBOutlet weak var workoutTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutTableView.dataSource = self
        workoutTableView.rowHeight = 80.0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startTimeString = dateFormatter.string(from: selectedWorkout?.startTime ?? Date())
        let endTimeString = dateFormatter.string(from: selectedWorkout?.endTime ?? Date())
        
        navigationItem.title = "\(startTimeString) - \(endTimeString)"
        
        configureBarButtonItems()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        workoutTableView.reloadData()
    }
    
    private func configureBarButtonItems() {
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(deleteButtonTapped))
        
        let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(editButtonTapped))
        deleteButton.tintColor = .orange
        editButton.tintColor = .orange
        
        navigationItem.rightBarButtonItems = [deleteButton, editButton]
    }
    
    
    @objc func deleteButtonTapped() {
        let alert = UIAlertController(title: "Are you sure you want to delete this workout?", message: "This action cannot be undone", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            if let workoutToDelete = self.selectedWorkout {
                do {
                    
                    try self.realm.write {
                        self.realm.delete(workoutToDelete)

                    }
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    print("Could not delete item \(error)")
                }
                
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel, handler: { _ in
            self.workoutTableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func editButtonTapped() {
        let destinationVC = EditWorkoutVC()
        destinationVC.realmWorkout = self.selectedWorkout
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
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
        cell.selectionStyle = .none
        return cell
    }
    
    
}
