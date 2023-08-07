//
//  EditWorkoutVC.swift
//  Squat Counter
//
//  Created by sam hastings on 03/08/2023.
//


import UIKit
import RealmSwift

class EditWorkoutVC: UITableViewController {
    
    var realmWorkout: RealmWorkout?
    var pickerView: UIPickerView!
    var currentEditingIndexPath: IndexPath?
    let exerciseNames = ["squat", "lunge"]
    var toolbar: UIToolbar?
//    var temporaryChanges: [String:RealmSet] = [:]
//    var saveButton = UIButton()
//    var cancelButton = UIButton()
    
    
    let darkBlue = UIColor(red: 0/255, green: 18/255, blue: 37/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "valueCell")
        tableView.backgroundColor = .black
        
        // Register a default header footer view
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
        // Set the navigation bar background color to black
        navigationController?.navigationBar.backgroundColor = .black
        
        // Set the navigation bar title and text color
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(.white)]
        navigationItem.title = "Edit Workout"
        
        // Set the back button color to system orange
        navigationController?.navigationBar.tintColor = .orange
        
        
//        // Add save button
//        saveButton.setTitle("Save Changes", for: .normal)
//        saveButton.backgroundColor = darkBlue
//        saveButton.setTitleColor(.orange, for: .normal)
//        saveButton.isEnabled = false
//        saveButton.alpha = 0.5
//        saveButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
//        saveButton.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40) // Adjust the size as needed
//        //saveButton.translatesAutoresizingMaskIntoConstraints = false
//        let saveButtonItem = UIBarButtonItem(customView: saveButton)
//
//        // Add saveButtonItem to the toolbar
//        navigationController?.toolbarItems = [saveButtonItem]
//        navigationController?.setToolbarHidden(false, animated: false)
        

        //navigationController?.setToolbarHidden(false, animated: true)
//        navigationController?.toolbar.addSubview(saveButton)
//        navigationController?.toolbar.leadingAnchor.constraint(equalTo: saveButton.leadingAnchor).isActive = true
//        navigationController?.toolbar.trailingAnchor.constraint(equalTo: saveButton.trailingAnchor).isActive = true
//        tabBarController?.tabBar.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 30.0).isActive = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
//            saveButton.isHidden = true
            navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    

    
//    @objc func saveChanges() {
//        print("tapped")
//        let realm = try! Realm()
//
//        try! realm.write {
//            for (setId, set) in temporaryChanges {
//                if let originalSet = realm.object(ofType: RealmSet.self, forPrimaryKey: setId) {
//                    originalSet.exerciseName = set.exerciseName
//                    originalSet.numReps = set.numReps
//                    originalSet.weightLbs = set.weightLbs
//                    originalSet.hasBeenEditted = true
//                }
//            }
//        }
//
//
//        // Clear temporary changes
////        temporaryChanges.removeAll()
//        navigationController?.setToolbarHidden(true, animated: true)
//        self.navigationController?.popViewController(animated: true)
//    }
    
 
    // MARK: - UITableViewDataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return realmWorkout?.sets.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // Three cells for exerciseName, numReps, weightLbs
    }
    

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        headerView?.textLabel?.text = "Set \(section + 1)"
        headerView?.textLabel?.textColor = .systemGray // Change to desired color
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "valueCell", for: indexPath)
        let set = realmWorkout?.sets[indexPath.section]
        
        var content = UIListContentConfiguration.valueCell()
        switch indexPath.row {
        case 0:
            content.text = "Exercise"
            content.secondaryText = set?.exerciseName
        case 1:
            content.text = "Reps"
            content.secondaryText = "\(set?.numReps ?? 0)"
        case 2:
            content.text = "Weight"
            content.secondaryText = "\(set?.weightLbs ?? 0)"
        default:
            break
        }
        
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .white
        
        cell.contentConfiguration = content
        cell.backgroundColor = .black
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissCurrentPicker()
        currentEditingIndexPath = indexPath
        pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        //hide the buttons
//        saveButton.isHidden = true
//        saveButton.isEnabled = false
//        saveButton.alpha = 0.5
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = .gray // Change to the desired tap color

        // Restore the original color after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            cell?.contentView.backgroundColor = .black // Change back to the original color
        }

        // Preselect the picker view's value
        let set = realmWorkout?.sets[indexPath.section]
//        let tempSet = temporaryChanges[set?.setId ?? ""]

        switch indexPath.row {
        case 0:
//            if let exerciseName = tempSet?.exerciseName, let index = exerciseNames.firstIndex(of: exerciseName) {
//                pickerView.selectRow(index, inComponent: 0, animated: false)
//            } else if let exerciseName = set?.exerciseName, let index = exerciseNames.firstIndex(of: exerciseName) {
//                pickerView.selectRow(index, inComponent: 0, animated: false)
//            }
            if let index = exerciseNames.firstIndex(of: (set?.exerciseName) ?? "squat") {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
            
        case 1:
//            if let numReps = tempSet?.numReps {
//                pickerView.selectRow(numReps - 1, inComponent: 0, animated: false)
//            } else {
//                pickerView.selectRow(set!.numReps - 1, inComponent: 0, animated: false)
//            }
            pickerView.selectRow(set!.numReps - 1, inComponent: 0, animated: false)
        case 2:
//            if let weightLbs = tempSet?.weightLbs {
//                pickerView.selectRow(weightLbs / 5, inComponent: 0, animated: false)
//            } else {
//                pickerView.selectRow(set!.weightLbs / 5, inComponent: 0, animated: false)
//            }
            pickerView.selectRow(set!.weightLbs / 5, inComponent: 0, animated: false)
        default: break
        }
        
        pickerView.backgroundColor = darkBlue

        // Add the picker view to the bottom of the screen (you can customize its frame as needed)
        pickerView.frame = CGRect(x: 0, y: view.frame.height - 200, width: view.frame.width, height: 100)
        view.addSubview(pickerView)
        
        // Create the toolbar
        let toolbar = UIToolbar()
        self.toolbar = toolbar
        toolbar.frame = CGRect(x: 0, y: pickerView.frame.origin.y - 44, width: view.frame.width, height: 44)


        // Create the "Done" button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))

        // Create a flexible space to center the buttons
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Set the toolbar's items
        toolbar.setItems([flexSpace, doneButton, flexSpace], animated: false)
        
        // Set the background color of the toolbar
        toolbar.barTintColor = darkBlue

        // Change the text color of the "Cancel" button
        //cancelButton.tintColor = .orange

        // Change the text color of the "Done" button
        doneButton.tintColor = .orange

        // Add the toolbar and picker view to the view hierarchy
        view.addSubview(toolbar)
        view.addSubview(pickerView)
    }
    

    @objc func donePicker() {
        //show the buttons
//        cancelButton.isHidden = false
//        saveButton.isHidden = false
        dismissCurrentPicker()
//        if temporaryChanges.count > 0 {
//            saveButton.isEnabled = true
//            saveButton.alpha = 1.0
//        }
    }
    
    func dismissCurrentPicker() {
        pickerView?.removeFromSuperview()
        toolbar?.removeFromSuperview()
        view.endEditing(true)
    }

}

//MARK: - UIPickerView extensions

extension EditWorkoutVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let indexPath = currentEditingIndexPath else {return 0}
        switch indexPath.row{
        case 0:
            return exerciseNames.count
        case 1:
            return 100
        case 2:
             return (300/5) + 1
        default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        guard let indexPath = currentEditingIndexPath else {return nil}
        switch indexPath.row{
        case 0:
            title = exerciseNames[row]
        case 1:
            title = "\(row + 1)"
        case 2:
             title = "\(row * 5)"
        default:
                title = "Data not found"
        }
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    
    // updates the relevant RealmSet and then reloads the tableView with the updated realmSet Values
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let indexPath = currentEditingIndexPath, let set = realmWorkout?.sets[indexPath.section] else {return}
//        let tempSet = temporaryChanges[set.setId] ?? RealmSet(value: set)
        var valueSelected: String?
//        switch indexPath.row{
//        case 0:
////            tempSet.exerciseName = exerciseNames[row]
//            valueSelected = exerciseNames[row]
//            set.exerciseName = exerciseNames[row]
//        case 1:
////            tempSet.numReps = row + 1
//            valueSelected = "\(row + 1)"
//            set.numReps = row + 1
//        case 2:
////            tempSet.weightLbs = row * 5
//            valueSelected = "\(row * 5)"
//            set.weightLbs = row * 5
//        default:
//            break
//        }
        do {
            let realm = try Realm()
            
            try realm.write {
                switch indexPath.row{
                case 0:
                    valueSelected = exerciseNames[row]
                    set.exerciseName = exerciseNames[row]
                case 1:
                    valueSelected = "\(row + 1)"
                    set.numReps = row + 1
                case 2:
                    valueSelected = "\(row * 5)"
                    set.weightLbs = row * 5
                default:
                    break
                }
                set.hasBeenEditted = true
            }
        } catch {
            print("Error updating Realm object: \(error)")
        }
        
//        temporaryChanges[set.setId] = tempSet
        DispatchQueue.main.async { [weak self] in
                // Update the table view cell's secondary text
            if let cell = self?.tableView.cellForRow(at: indexPath), var content = cell.contentConfiguration as? UIListContentConfiguration {
                content.secondaryText = valueSelected
                cell.contentConfiguration = content
            }
        }
    }
}
