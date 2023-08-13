//
//  RestVC.swift
//  Squat Counter
//
//  Created by sam hastings on 18/07/2023.
//

import UIKit


protocol RestVCDelegate: AnyObject {
    func didDismissOverlay(repTarget: Int, setTarget: Int, weightOnBar: Int)
}

class RestVC: UIViewController {
    
    // NAVIGATION
    weak var delegate: RestVCDelegate?
    var countdown: CountdownTimer?
    let formatter = DateComponentsFormatter()
    var timer: Timer?
    var initialRestInterval: Int?
    var repTarget = 10
    var setTarget = 10
    var weightOnBar = 100
    var setsCompleted = 5
    var largeCountdownLabel: UILabel!

    
    
    

    //MARK: - IBOutlets
    
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var setCompletedLabel: UILabel!
    @IBOutlet weak var remainingSetsLabel: UILabel!
    @IBOutlet weak var targetRepsLabel: UILabel!
    @IBOutlet weak var weightOnBarLabel: UILabel!
    
    @IBOutlet weak var reduceButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var fewerSetsButton: UIButton!
    @IBOutlet weak var moreSetsButton: UIButton!
    
    @IBOutlet weak var fewerRepsButton: UIButton!
    @IBOutlet weak var moreRepsButton: UIButton!
    
    @IBOutlet weak var lessWeightButton: UIButton!
    @IBOutlet weak var moreWeightButton: UIButton!
    
    //MARK: - IBActions
    
    @IBAction func reduceRestButton(_ sender: Any) {
        countdown?.adjustRemainingTime(secondsDelta: -10)
    }
    @IBAction func addRestButton(_ sender: Any) {
        countdown?.adjustRemainingTime(secondsDelta: 10)
    }
    
    @IBAction func fewerSetsButtonTapped(_ sender: UIButton) {
        if setTarget - setsCompleted > 0 {
            setTarget -= 1
            if setTarget - setsCompleted == 0 {
                remainingSetsLabel.text = "No set target"
            } else if setTarget - setsCompleted == 1 {
                remainingSetsLabel.text = "\(setTarget-setsCompleted) more set"
            } else {
                remainingSetsLabel.text = "\(setTarget-setsCompleted) more sets"
            }
        }
    }
    
    @IBAction func moreSetsButtonTapped(_ sender: UIButton) {
        if setTarget-setsCompleted < 1 {
            setTarget = setsCompleted + 1
            remainingSetsLabel.text = "\(setTarget-setsCompleted) more set"
        } else {
            setTarget += 1
            remainingSetsLabel.text = "\(setTarget-setsCompleted) more sets"
        }
        
    }
    
    @IBAction func fewerRepsButtonTapped(_ sender: UIButton) {
        if repTarget > 0 {
            repTarget -= 1
            if repTarget == 0 {
                targetRepsLabel.text = "No target"
            } else {
                targetRepsLabel.text = "\(repTarget) reps"
            }
            
        }
        
        
    }
    
    @IBAction func moreRepsButtonTapped(_ sender: UIButton) {
        repTarget += 1
        targetRepsLabel.text = "\(repTarget) reps"
    }
    
    @IBAction func lessWeightButtonTapped(_ sender: UIButton) {
        if weightOnBar > 0 {
            weightOnBar -= 5
            if weightOnBar == 0 {
                weightOnBarLabel.text = "Bodyweight"
            } else {
                weightOnBarLabel.text = "\(weightOnBar) lbs"
            }
            
        }
    }
    
    @IBAction func moreWeightButtonTapped(_ sender: UIButton) {
        weightOnBar += 5
        weightOnBarLabel.text = "\(weightOnBar) lbs"
    }
    
    @IBAction func dismissOverlayButton(_ sender: Any) {
        // NAVIGATION
        hide()
    }
    
    //MARK: - View Controller
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        // Disable phone from going to sleep when app is idle
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Configure the large countdown text
        largeCountdownLabel = UILabel()
        largeCountdownLabel.font = UIFont.systemFont(ofSize: 400, weight: .bold) // Large font size
        largeCountdownLabel.textColor = .white // White text
        largeCountdownLabel.textAlignment = .center // Center aligned
        largeCountdownLabel.adjustsFontSizeToFitWidth = true // Adjust font size to fit width
        largeCountdownLabel.minimumScaleFactor = 0.2 // Set minimum scale factor
        largeCountdownLabel.numberOfLines = 1 // Ensure the text stays in one line
        largeCountdownLabel.isHidden = true // Initially hidden

        self.view.addSubview(largeCountdownLabel)

        // Constraints to center the label
        largeCountdownLabel.translatesAutoresizingMaskIntoConstraints = false
        largeCountdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        largeCountdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        largeCountdownLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        largeCountdownLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        
        setCompletedLabel.text = "Set #\(setsCompleted) complete"
        remainingSetsLabel.text = (setTarget == 0 ? "No set target" : "\(setTarget-setsCompleted) more sets")
        targetRepsLabel.text = (repTarget == 0 ? "No rep target" : "\(repTarget) reps")
        weightOnBarLabel.text = (weightOnBar == 0 ? "Bodyweight" : "\(weightOnBar) lbs")
        
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let largeSymbolImage = UIImage(systemName: "minus.circle.fill", withConfiguration: largeConfig)
        reduceButton.setImage(largeSymbolImage, for: .normal)
        fewerSetsButton.setImage(largeSymbolImage, for: .normal)
        fewerRepsButton.setImage(largeSymbolImage, for: .normal)
        lessWeightButton.setImage(largeSymbolImage, for: .normal)
        let largeAddConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let largeAddSymbolImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeAddConfig)
        addButton.setImage(largeAddSymbolImage, for: .normal)
        moreSetsButton.setImage(largeAddSymbolImage, for: .normal)
        moreRepsButton.setImage(largeAddSymbolImage, for: .normal)
        moreWeightButton.setImage(largeAddSymbolImage, for: .normal)
        

        configView()
        countdown = CountdownTimer(time: initialRestInterval ?? 60)
        countdown?.start(completion: {
            // NAVIGATION
            self.hide()
        })
        // Timer to update UI label
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let remainingTime = self.countdown?.getTimeRemaining() ?? 0
            DispatchQueue.main.async {
                //self.countdownTimer.text = String(self.countdown?.getTimeRemaining() ?? 0)
                self.countdownTimer.text = self.formatter.string(from: TimeInterval(remainingTime))
                
                // update the largeCountdownLabel text
                if remainingTime == 0 {
                    self.largeCountdownLabel.text = "GO!"
                    self.largeCountdownLabel.isHidden = false }
                else if remainingTime <= 3 {
                    self.largeCountdownLabel.text = "\(remainingTime)"
                    self.largeCountdownLabel.isHidden = false
                } else {
                    self.largeCountdownLabel.isHidden = true
                }
            }
        }
        self.countdownTimer.text = self.formatter.string(from: TimeInterval(initialRestInterval ?? 60))
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // NAVIGATION
    func configView() {
        // This makes the background transparent
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        // This creates and applies a blur effect
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.view.insertSubview(blurEffectView, at: 0)

        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        show()
    }
    

    func appear(sender: UIViewController) {
        sender.present(self, animated: true){
            self.show()
        }
    }
    

    private func show() {
        UIView.animate(withDuration: 1, delay: 0.1) {
            self.contentView.alpha = 1
        }
    }
    

    func hide() {
        largeCountdownLabel.isHidden = true
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseOut) {
            self.contentView.alpha = 0
        } completion: { _ in
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didDismissOverlay(repTarget: self.repTarget, setTarget: self.setTarget, weightOnBar: self.weightOnBar)
        }
    }

  

}
