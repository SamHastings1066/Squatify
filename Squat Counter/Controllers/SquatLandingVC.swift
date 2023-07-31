//
//  SquatLandingVC.swift
//  Squat Counter
//
//  Created by sam hastings on 27/07/2023.
//

import UIKit

class SquatLandingVC: UIViewController {
    
    var repData = Array(1...50).map{String($0)}
    var setData = Array(1...20).map{String($0)}
    var weightData = Array(1...60).map{ "\($0 * 5)" }
    let restData = [Array(0...59),Array(0...59)]
    
    var repPickerView: UIPickerView?
    var setPickerView: UIPickerView?
    var weightPickerView: UIPickerView?
    var restPickerView: UIPickerView?
    
    var mins = 1
    var secs = 0
    
    // Default values for a squat workout
    var repTarget = 0
    var setTarget = 0
    var weightOnBar = 0
    var restInterval = 60 //seconds


    
    //MARK: - IBOutlets
    
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var repTargetTextfield: UITextField!
    @IBOutlet weak var setTargetTextfield: UITextField!
    @IBOutlet weak var weightTargetTextfield: UITextField!
    @IBOutlet weak var restTargetTextfield: UITextField!
    
    //MARK: - IBActions
    
    @IBAction func didTapStartSquatting(_ sender: UIButton) {
        self.hidesBottomBarWhenPushed = true
//        self.navigationItem.hidesBackButton = true
        performSegue(withIdentifier: "SquatSegue", sender: self)
        self.hidesBottomBarWhenPushed = false

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        repPickerView = createPickerView()
        setPickerView = createPickerView()
        weightPickerView = createPickerView()
        restPickerView = createPickerView()
        
        repData.insert("No Target", at: 0)
        setData.insert("No Target", at: 0)
        weightData.insert("Bodyweight", at: 0)
        descriptionView.layer.cornerRadius = 10
        repTargetTextfield.inputView = repPickerView
        repTargetTextfield.inputAccessoryView = createToolBar(selector: #selector(doneRepPicker))
        setTargetTextfield.inputView = setPickerView
        setTargetTextfield.inputAccessoryView = createToolBar(selector: #selector(doneSetPicker))
        weightTargetTextfield.inputView = weightPickerView
        weightTargetTextfield.inputAccessoryView = createToolBar(selector: #selector(doneWeightPicker))
        restTargetTextfield.inputView = restPickerView
        restTargetTextfield.inputAccessoryView = createToolBar(selector: #selector(doneRestPicker))
        UITextField.appearance().tintColor = .clear
        

        repTargetTextfield.inputAccessoryView?.layoutIfNeeded()
        setTargetTextfield.inputAccessoryView?.layoutIfNeeded()
        weightTargetTextfield.inputAccessoryView?.layoutIfNeeded()
        restTargetTextfield.inputAccessoryView?.layoutIfNeeded()
        
        repTargetTextfield.textAlignment = .center
        setTargetTextfield.textAlignment = .center
        restTargetTextfield.textAlignment = .center
        
        repPickerView!.delegate = self
        setPickerView!.delegate = self
        weightPickerView!.delegate = self
        restPickerView!.delegate = self
        repPickerView!.dataSource = self
        setPickerView!.dataSource = self
        weightPickerView!.dataSource = self
        restPickerView!.dataSource = self
        
        restPickerView!.selectRow(1, inComponent:0, animated:false)

    }
    
    func createPickerView() -> UIPickerView {
        let pickerView = UIPickerView(frame: CGRectMake(0, 200, view.frame.width, 150))
        pickerView.backgroundColor = UIColor(red: 0/255, green: 18/255, blue: 37/255, alpha: 1)
        return pickerView
    }
    
    func createToolBar(selector: Selector) -> UIToolbar {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = false
        toolBar.barTintColor = UIColor(red: 0/255, green: 18/255, blue: 37/255, alpha: 1)
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: selector)
        doneButton.tintColor = .orange

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.setItems([flexibleSpace, doneButton, flexibleSpace], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        toolBar.layoutIfNeeded()  // Force layout

        return toolBar
    }

    // These functions to handle done button tap for each picker
    @objc func doneRepPicker() {
        repTargetTextfield.resignFirstResponder()
    }

    @objc func doneSetPicker() {
        setTargetTextfield.resignFirstResponder()
    }

    @objc func doneWeightPicker() {
        weightTargetTextfield.resignFirstResponder()
    }

    @objc func doneRestPicker() {
        restTargetTextfield.resignFirstResponder()
    }

}

//MARK: - Extensions

extension SquatLandingVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == restPickerView {
            return 2
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // if this doesn't work cahnge to pickerView.tag
        switch pickerView {
            case repPickerView:
                return repData.count
            case setPickerView:
                return setData.count
            case weightPickerView:
                return weightData.count
            case restPickerView:
                return restData[component].count
            default:
                return 1
        }
    }
    
    // Implement the UIPickerViewDelegate's pickerView(_:attributedTitleForRow:forComponent:) method
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        switch pickerView {
        case repPickerView:
            title = "\(repData[row])"
        case setPickerView:
            title = "\(setData[row])"
        case weightPickerView:
            if weightData[row] == "Bodyweight" {
                title = "\(weightData[row])"
            } else {
                title = "+\(weightData[row])lbs"
            }
            
        case restPickerView:
            if component == 0 {
                title = "\(restData[component][row]) Mins"
            } else {
                title = "\(restData[component][row]) Secs"
            }
        default:
            title = "Data not found"
        }
        // Return the title as an attributed string with a white color
        return NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
            case repPickerView:
                repTargetTextfield.text = "\(repData[row])"
                if repData[row] == "No Target" {
                        repTarget = 0
                } else {
                    repTarget = Int(repData[row])!
                }
            case setPickerView:
                setTargetTextfield.text = "\(setData[row])"
                if setData[row] == "No Target" {
                        setTarget = 0
                } else {
                    setTarget = Int(setData[row])!
                }
            case weightPickerView:
                weightTargetTextfield.text = "\(weightData[row])"
                if weightData[row] == "Bodyweight" {
                        weightOnBar = 0
                } else {
                    weightOnBar = Int(weightData[row])!
                }
            case restPickerView:
                if component == 0 {
                    mins = restData[component][row]
                } else {
                    secs =  restData[component][row]
                }
                let duration = Duration.seconds(mins * 60 + secs)
            let format = duration.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
                restTargetTextfield.text = format
                //restTargetTextfield.resignFirstResponder()
            default:
                return
        }
    }
}


