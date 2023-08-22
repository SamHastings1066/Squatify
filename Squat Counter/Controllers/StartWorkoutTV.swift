//
//  StartWorkoutTVTableViewController.swift
//  Squat Counter
//
//  Created by sam hastings on 08/08/2023.
//

import UIKit

class StartWorkoutTV: UITableViewController {
    
    let repTargetArray = Array(0...50)
    let setTargetArray = Array(0...20)
    let weightArray = Array(0...60).map{$0 * 5}
    let restIntervalArraySeconds = Array(0...2599)
    
    var repTarget = 0
    var setTarget = 0
    var weight = 0
    var restIntervalSeconds = 60
    
    var overlayView: UIView?
    var tapGestureRecognizer: UITapGestureRecognizer?
    
    
    let sectionTitles = [
        "Target number of reps",
        "Target number of sets",
        "Weight",
        "Rest interval between sets"
    ]
    
    var cellTexts = [
        "No rep target",
        "No set target",
        "Bodyweight",
        "01:00"
    ]
    
    var toolbar: UIToolbar?
    var pickerView: UIPickerView!
    let darkBlue = UIColor(red: 0/255, green: 18/255, blue: 37/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        
        // Add the header view with user instructions
        
        let headerLabel = UILabel()
        headerLabel.text = "Set target reps, sets and rest interval for your workout. You can change these while resting between sets."
        headerLabel.numberOfLines = 0
        headerLabel.textColor = .white
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 120))
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 15),
            headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -15)
        ])
        
        tableView.tableHeaderView = headerView
        

        // set up buttons below tableView
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Squatting", for: .normal)
        startButton.setTitleColor(.orange, for: .normal)
        startButton.addTarget(self, action: #selector(startSquatting), for: .touchUpInside)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        startButton.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        customView.addSubview(startButton)

        // Center the button horizontally
        startButton.centerXAnchor.constraint(equalTo: customView.centerXAnchor).isActive = true
        // Set the top constraint 20 points from the top of customView
        startButton.topAnchor.constraint(equalTo: customView.topAnchor, constant: 50).isActive = true

        tableView.tableFooterView = customView
        
        view.backgroundColor = .black
        tableView.backgroundColor = .black

    }
    
    //MARK: - Navigation
    
    @objc func startSquatting() {
        
        let introVC = IntroductionVideo()
        introVC.repTarget = repTarget
        introVC.setTarget = setTarget
        introVC.weightOnBar = weight
        introVC.restInterval = restIntervalSeconds
        
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(introVC, animated: false)
        self.hidesBottomBarWhenPushed = false
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Reset cellTexts to starting value
        cellTexts = [
            "No rep target",
            "No set target",
            "Bodyweight",
            "01:00"
        ]
        tableView.reloadData()
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .black // Or any background color you want
        let titleLabel = UILabel()
        titleLabel.text = sectionTitles[section]
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
        
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40 // You can adjust the height as needed
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
//        var content = cell.defaultContentConfiguration()
        var content = UIListContentConfiguration.valueCell()
        content.text = cellTexts[indexPath.section]
        content.secondaryText = "Edit"
        content.textProperties.color = .white
        content.secondaryTextProperties.color = .lightGray
        cell.contentConfiguration = content
        cell.backgroundColor = .black

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.tag = indexPath.section // Use the tag to identify which section the picker corresponds to

        // Optionally set the selected row to the current value
        switch indexPath.section {
        case 0:
            pickerView.selectRow(repTarget, inComponent: 0, animated: false)
        case 1:
            pickerView.selectRow(setTarget, inComponent: 0, animated: false)
        case 2:
            pickerView.selectRow(weight / 5, inComponent: 0, animated: false) // assuming weight increments of 5
        case 3:
            pickerView.selectRow(restIntervalSeconds / 60, inComponent: 0, animated: false) // minutes
            pickerView.selectRow(restIntervalSeconds % 60, inComponent: 2, animated: false) // seconds
        default:
            break
        }

        pickerView.backgroundColor = darkBlue
        guard let window = (self.view.window?.windowScene?.windows.first { $0.isKeyWindow }) else { return }

        // This gets the height of the tab bar.
        let pickerViewHeight: CGFloat = 100

        // Adjust the y-origin of the picker view based on the height of the tab bar.
        let pickerViewY: CGFloat = UIScreen.main.bounds.height - pickerViewHeight - window.safeAreaInsets.bottom
        pickerView.frame = CGRect(x: 0, y: pickerViewY, width: view.frame.width, height: pickerViewHeight)

        let toolbar = UIToolbar()
        self.toolbar = toolbar
        toolbar.frame = CGRect(x: 0, y: pickerViewY - 44, width: view.frame.width, height: 44)
        toolbar.barTintColor = darkBlue

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexSpace, doneButton, flexSpace], animated: false)
        doneButton.tintColor = .orange
        
        overlayView = UIView(frame: window.bounds)
        overlayView?.backgroundColor = UIColor(white: 0, alpha: 0.6) // semi-transparent black
        window.insertSubview(overlayView!, belowSubview: toolbar) // add it below the toolbar

        window.addSubview(toolbar)
        window.addSubview(pickerView)
        
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
//        // Set the frame for the picker at the bottom of the view
//        let pickerViewHeight: CGFloat = 130
//        let tabBarHeight: CGFloat = tabBarController?.tabBar.frame.height ?? 0 // If there's no tab bar controller, this will be 0
//        pickerView.frame = CGRect(x: 0, y: view.frame.height - pickerViewHeight - tabBarHeight, width: view.frame.width, height: pickerViewHeight)
//        pickerView.backgroundColor = darkBlue
//
//        let toolbar = UIToolbar()
//        self.toolbar = toolbar
//        toolbar.frame = CGRect(x: 0, y: pickerView.frame.origin.y - 44, width: view.frame.width, height: 44)
//        toolbar.barTintColor = darkBlue
//
//
//        // Create the "Done" button
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePicker))
//        doneButton.tintColor = .orange
//
//        // Create a flexible space to center the buttons
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//
//        // Set the toolbar's items
//        toolbar.setItems([flexSpace, doneButton, flexSpace], animated: false)
//
//        // Add the toolbar and picker view to the view hierarchy
//        view.addSubview(toolbar)
//        view.addSubview(pickerView)
//
//        // Add a tap gesture recognizer to detect taps outside the picker
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsidePicker(_:)))
//        view.addGestureRecognizer(tapGesture)
//    }
//
//    @objc func donePicker() {
//        pickerView?.removeFromSuperview()
//        toolbar?.removeFromSuperview()
//        view.endEditing(true)
//    }
//
//    @objc func handleTapOutsidePicker(_ gesture: UITapGestureRecognizer) {
//        let touchPoint = gesture.location(in: view)
//        for subview in view.subviews {
//            if let picker = subview as? UIPickerView, picker.frame.contains(touchPoint) {
//                return // Touch is inside the picker, so do nothing
//            }
//        }
//
//        // Touch is outside the picker, so remove it
//        for subview in view.subviews {
//            if let picker = subview as? UIPickerView {
//                picker.removeFromSuperview()
//                toolbar?.removeFromSuperview()
//            }
//        }
//
//
//        // Remove the gesture recognizer
//        view.removeGestureRecognizer(gesture)
//
//        // Find the table view cell that was tapped
//        let touchPointInTableView = gesture.location(in: tableView)
//        if let indexPath = tableView.indexPathForRow(at: touchPointInTableView) {
//            tableView(tableView, didSelectRowAt: indexPath)
//        }
//    }
    
}


//MARK: - PickerView methods

extension StartWorkoutTV: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView.tag {
        case 3:
            return 3
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return repTargetArray.count
        case 1:
            return setTargetArray.count
        case 2:
            return weightArray.count
        case 3:
            switch component {
                case 0:
                    return 60 // 60 options for minutes
                case 1:
                    return 1 // 1 option for colon
                case 2:
                    return 60 // 60 options for seconds
                default:
                    return 0
                }
        default:
            return 0
        }
    }
    
//    // Define how each row should be displayed
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch pickerView.tag {
//        case 0:
//            return repTargetArray[row] == 0 ? "No rep target" : "\(repTargetArray[row]) reps"
//        case 1:
//            return setTargetArray[row] == 0 ? "No set target" : "\(setTargetArray[row]) sets"
//        case 2:
//            return weightArray[row] == 0 ? "Bodyweight" : "\(weightArray[row]) lbs"
//        case 3:
//            switch component {
//            case 0:
//                return "\(String(format: "%02d", row)) mins"
//            case 1:
//                return ":" // Static colon text
//            case 2:
//                return "\(String(format: "%02d", row)) secs"
//            default:
//                return ""
//            }
//        default:
//            return ""
//        }
//    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        switch pickerView.tag {
        case 0:
            title = repTargetArray[row] == 0 ? "No rep target" : "\(repTargetArray[row]) reps"
        case 1:
            title = setTargetArray[row] == 0 ? "No set target" : "\(setTargetArray[row]) sets"
        case 2:
            title = weightArray[row] == 0 ? "Bodyweight" : "\(weightArray[row]) lbs"
        case 3:
            switch component {
            case 0:
                title = "\(String(format: "%02d", row)) mins"
            case 1:
                title = ":" // Static colon text
            case 2:
                title = "\(String(format: "%02d", row)) secs"
            default:
                title = ""
            }
        default:
            title = ""
        }
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch pickerView.tag {
        case 3:
            switch component {
            case 0, 2: // Minute and second components
                return 110 // Narrower width
            case 1: // Colon component
                return 50 // Even narrower width for the colon
            default:
                return 0
            }
        default:
            return view.frame.width// Default width for other pickers
        }
    }
    
    // Handle what happens when a row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 0:
            repTarget = repTargetArray[row]
            updateCellText(atSection: 0, withValue: repTarget == 0 ? "No rep target" : "\(repTarget)")
        case 1:
            setTarget = setTargetArray[row]
            updateCellText(atSection: 1, withValue: setTarget == 0 ? "No set target" : "\(setTarget)")
        case 2:
            weight = weightArray[row]
            updateCellText(atSection: 2, withValue: weight == 0 ? "Bodyweight" : "\(weight) lbs")
        case 3:
            let minutes = pickerView.selectedRow(inComponent: 0)
            let seconds = pickerView.selectedRow(inComponent: 2)
            restIntervalSeconds = minutes * 60 + seconds
            updateCellText(atSection: 3, withValue: String(format: "%02d:%02d", minutes, seconds))
        default:
            break
        }
    }
    
    func updateCellText(atSection section: Int, withValue value: String) {
        cellTexts[section] = value
        let indexPath = IndexPath(row: 0, section: section)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

