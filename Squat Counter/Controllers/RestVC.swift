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
    var startOverlayTimerHasBeenStarted = false

    
    
    

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
        countdown?.start()
        // Timer to update UI label
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let remainingTime = self.countdown?.getTimeRemaining() ?? 0
            DispatchQueue.main.async {
                //self.countdownTimer.text = String(self.countdown?.getTimeRemaining() ?? 0)
                self.countdownTimer.text = self.formatter.string(from: TimeInterval(remainingTime))
                if remainingTime == 0 && !self.startOverlayTimerHasBeenStarted {
                    self.startOverlayTimerHasBeenStarted = true
                    self.startOverlayTimer()
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
        //largeCountdownLabel.isHidden = true
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseOut) {
            self.contentView.alpha = 0
        } completion: { _ in
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didDismissOverlay(repTarget: self.repTarget, setTarget: self.setTarget, weightOnBar: self.weightOnBar)
        }
    }
    
    func startOverlayTimer() {

        let safeArea = view.safeAreaLayoutGuide
        // Create a view to cover the entire screen
        let countdownView = UIView(frame: safeArea.layoutFrame)
        countdownView.backgroundColor = .black
        view.addSubview(countdownView)

        // Create a label to display the countdown
        let countdownLabel = UILabel()
        countdownLabel.font = UIFont.systemFont(ofSize: 400, weight: .bold)
        countdownLabel.textColor = .white
        countdownLabel.textAlignment = .center
        countdownLabel.alpha = 1.0 // Make sure the label is initially visible
        
        countdownLabel.adjustsFontSizeToFitWidth = true // Adjust font size to fit width
        countdownLabel.minimumScaleFactor = 0.2 // Set minimum scale factor
        countdownLabel.numberOfLines = 1 // Ensure the text stays in one line
        countdownView.addSubview(countdownLabel)

        // Constraints to center the label
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.centerXAnchor.constraint(equalTo: countdownView.centerXAnchor).isActive = true
        countdownLabel.centerYAnchor.constraint(equalTo: countdownView.centerYAnchor).isActive = true
        countdownLabel.leadingAnchor.constraint(equalTo: countdownView.leadingAnchor).isActive = true
        countdownLabel.trailingAnchor.constraint(equalTo: countdownView.trailingAnchor).isActive = true
        
        
        // Start the countdown animation
        animateCountdown(from: 3, label: countdownLabel, completion: { [weak self] in
            countdownView.removeFromSuperview()
            self?.hide()
        })
    }
    
    func animateCountdown(from startNumber: Int, label: UILabel, completion: @escaping () -> Void) {
        label.text = "\(startNumber)"
        UIView.animate(withDuration: 1, animations: {
            label.alpha = 0.0
        }) { _ in
            if startNumber > 1 {
                label.text = "\(startNumber - 1)"
                label.alpha = 1.0
                self.animateCountdown(from: startNumber - 1, label: label, completion: completion)
            } else {
                label.text = "GO!"
                label.alpha = 1.0
                // Delaying the transition to the next view controller to let "GO!" be visible
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion()
                }
            }
        }
    }

  

}
