//
//  FinishWorkoutTV.swift
//  Squat Counter
//
//  Created by sam hastings on 09/08/2023.
//

import UIKit
import RealmSwift

class FinishWorkoutTV: UITableViewController {
    
    var realmWorkout: RealmWorkout?
    var workoutSets: [RealmSet]?
    var toolbar: UIToolbar?
    var pickerView: UIPickerView!
    let darkBlue = UIColor(red: 0/255, green: 18/255, blue: 37/255, alpha: 1)
    // Create Date Formatter
    let dateFormatter = DateFormatter()
    var currentEditingIndexPath: IndexPath?
    var overlayView: UIView?
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    let repsArray = Array(0...50)
    let weightArray = Array(0...60).map{$0 * 5}
    let exerciserArray = ["squat", "lunge"]
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up page title
        navigationItem.title = "Workout Summary"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        // Add the header view with user instructions

        let dateLabel = UILabel()
        dateLabel.textColor = .white
        dateFormatter.dateFormat = "EE, MMM d"
        let dateString = dateFormatter.string(from: realmWorkout?.startTime ?? Date())

        // Format start and end times with 12-hour clock
        let timeLabel = UILabel()
        timeLabel.textColor = .white
        dateFormatter.dateFormat = "h:mm a"
        let startString = dateFormatter.string(from: realmWorkout?.startTime ?? Date())
        let endString = dateFormatter.string(from: realmWorkout?.endTime ?? Date())

        dateLabel.text = "\(dateString)"
        dateLabel.numberOfLines = 0
        dateLabel.textAlignment = .center
        
        timeLabel.text = "\(startString) - \(endString)"
        timeLabel.numberOfLines = 0
        timeLabel.textAlignment = .center
        

        let dateStack = UIStackView()
        dateStack.axis = .horizontal
        dateStack.alignment = .center // Center alignment for vertical axis
        dateStack.distribution = .fillEqually // Distribute subviews equally
        dateStack.addArrangedSubview(dateLabel)
        dateStack.addArrangedSubview(timeLabel)

        // Set up the header view with a fixed height
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        dateStack.frame = headerView.bounds
        headerView.addSubview(dateStack)
        tableView.tableHeaderView = dateStack
        
//        // set up buttons below tableView
//        let customView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
//        let doneButton = UIButton(type: .system)
//        doneButton.setTitle("Done", for: .normal)
//        doneButton.setTitleColor(.orange, for: .normal)
//        doneButton.addTarget(self, action: #selector(finishWorkout), for: .touchUpInside)
//        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
//        doneButton.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
//        customView.addSubview(doneButton)
//
//        // Center the button horizontally
//        doneButton.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
//        // Set the top constraint 20 points from the top of customView
//        doneButton.topAnchor.constraint(equalTo: customView.topAnchor, constant: 50).isActive = true
//
//        tableView.tableFooterView = customView
        
        view.backgroundColor = .black
        tableView.backgroundColor = .black
        
        let doneBarButton = UIBarButtonItem()
        doneBarButton.title = "Finish"
        doneBarButton.target = self
        doneBarButton.action = #selector(finishWorkout)
    
        self.navigationItem.rightBarButtonItem = doneBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unhide the navigation bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Disable the back button
        navigationItem.hidesBackButton = true
    }
    
    //MARK: - Navigation
    
    @objc func finishWorkout() {
        // Switch to the "Calendar" tab
        self.navigationController?.tabBarController?.selectedIndex = 0
        
        // Get the "Calendar" navigation controller
        if let calendarNavController = self.navigationController?.tabBarController?.viewControllers?[0] as? UINavigationController {
            // Pop to the root view controller in the "Calendar" navigation stack
            calendarNavController.popToRootViewController(animated: false)
        }
        
        // Pop to the root view controller in the current ("Squats") navigation stack
        self.navigationController?.popToRootViewController(animated: false)
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return realmWorkout?.sets.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .black // Or any background color you want
        let titleLabel = UILabel()
        titleLabel.text = "Set \(section + 1)"
        titleLabel.textColor = .lightGray
        titleLabel.font = UIFont.systemFont(ofSize: 14.0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -5)
        ])
        //titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20).isActive = true
        //titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // You can adjust the height as needed
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        var content = UIListContentConfiguration.valueCell()
        var weightString: String?
        if let currentSet = realmWorkout?.sets[indexPath.section] {
            print("weight is \(currentSet.weightLbs)")
            if currentSet.weightLbs != 0 {
                weightString = "\(currentSet.weightLbs)lbs"
            }
            content.text = "\(currentSet.numReps) x \(weightString ?? "bodyweight") \(currentSet.exerciseName ?? "no exercise")s"
            content.secondaryText = "Edit"
            content.image = UIImage(systemName: "dumbbell")
            // Customize appearance.
            content.imageProperties.tintColor = .orange
            content.textProperties.color = .white
            content.secondaryTextProperties.color = .gray
        }
        cell.contentConfiguration = content
        cell.backgroundColor = .black
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        currentEditingIndexPath = indexPath

        // Preselect the picker view's value
        let set = realmWorkout?.sets[indexPath.section]
        
        let toolbar = UIToolbar()
        self.toolbar = toolbar
        guard let window = (self.view.window?.windowScene?.windows.first { $0.isKeyWindow }) else { return }
        overlayView = UIView(frame: window.bounds)
        overlayView?.backgroundColor = UIColor(white: 0, alpha: 0.6) // semi-transparent black
        window.insertSubview(overlayView!, belowSubview: toolbar) // add it below the toolbar

        window.addSubview(toolbar)
        window.addSubview(pickerView)


        // Set the selected row to current value
        pickerView.selectRow(set?.numReps ?? 0, inComponent: 0, animated: false) // reps
        pickerView.selectRow((set?.weightLbs ?? 0) / 5, inComponent: 1, animated: false) // weight
        if let index = exerciserArray.firstIndex(of: (set?.exerciseName) ?? "squat") {
            pickerView.selectRow(index, inComponent: 2, animated: false)
        }
        
        pickerView.backgroundColor = darkBlue
        

        // This gets the height of the tab bar.
        let pickerViewHeight: CGFloat = 100

        // Adjust the y-origin of the picker view based on the height of the tab bar.
        let pickerViewY: CGFloat = UIScreen.main.bounds.height - pickerViewHeight - window.safeAreaInsets.bottom
        pickerView.frame = CGRect(x: 0, y: pickerViewY, width: view.frame.width, height: pickerViewHeight)

        
        toolbar.frame = CGRect(x: 0, y: pickerViewY - 44, width: view.frame.width, height: 44)
        toolbar.barTintColor = darkBlue

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexSpace, doneButton, flexSpace], animated: false)
        doneButton.tintColor = .orange
        
        
        
        // Add a tap gesture recognizer to detect taps outside the picker
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsidePicker(_:)))
        window.addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc func handleTapOutsidePicker(_ gesture: UITapGestureRecognizer) {
        //let touchPoint = gesture.location(in: self.view.window)
        // Regardless of where the touch is, dismiss the picker
        dismissCurrentPicker()
        self.view.window?.removeGestureRecognizer(tapGestureRecognizer!)
        tapGestureRecognizer = nil
    }

    @objc func donePicker() {
        dismissCurrentPicker()
        self.view.window?.removeGestureRecognizer(tapGestureRecognizer!)
        tapGestureRecognizer = nil
    }
    
    func dismissCurrentPicker() {
        guard let window = (self.view.window?.windowScene?.windows.first { $0.isKeyWindow }) else { return }
        pickerView?.removeFromSuperview()
        toolbar?.removeFromSuperview()
        //view.endEditing(true)
        window.endEditing(true)
        overlayView?.removeFromSuperview()
        overlayView = nil


    }
    
}

//MARK: - PickerView methods

extension FinishWorkoutTV: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
 
            switch component {
                case 0:
                    return repsArray.count
                case 1:
                    return weightArray.count
                case 2:
                    return exerciserArray.count
                default:
                    return 0
                }

    }
    

    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""

            switch component {
            case 0:
                title = "\(repsArray[row]) reps"
            case 1:
                title = "\(weightArray[row])lbs" // Static colon text
            case 2:
                title = "\(exerciserArray[row])s"
            default:
                title = ""
            }

        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    

    
    // Handle what happens when a row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let indexPath = currentEditingIndexPath, let set = realmWorkout?.sets[indexPath.section] else { return }
        
        // Updating the relevant set properties and saving to Realm
        do {
            try realm.write {
                switch component {
                case 0:
                    set.numReps = repsArray[row]
                case 1:
                    set.weightLbs = weightArray[row]
                case 2:
                    set.exerciseName = exerciserArray[row]
                default:
                    break
                }
                
                // Always setting the hasBeenEdited flag to true
                set.hasBeenEditted = true
            }
        } catch {
            print("Error writing to realm \(error)")
        }
        
        
        
        // Update the cell text
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) {
            var content = UIListContentConfiguration.valueCell()
            let weightString = set.weightLbs == 0 ? "bodyweight" : "\(set.weightLbs)lbs"
            content.text = "\(set.numReps) x \(weightString) \(set.exerciseName ?? "no exercise")s"
            content.secondaryText = "Edit"
            content.image = UIImage(systemName: "dumbbell")
            content.imageProperties.tintColor = .orange
            content.textProperties.color = .white
            content.secondaryTextProperties.color = .gray
            cell.contentConfiguration = content
        }
    }


}
