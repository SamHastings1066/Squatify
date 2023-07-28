//
//  RestVC.swift
//  Squat Counter
//
//  Created by sam hastings on 18/07/2023.
//

import UIKit


protocol RestVCDelegate: AnyObject {
    func didDismissOverlay()
}

class RestVC: UIViewController {
    
    // NAVIGATION
    weak var delegate: RestVCDelegate?
    var countdown: CountdownTimer?
    let formatter = DateComponentsFormatter()
    var timer: Timer?
    
    
    

    //MARK: - IBOutlets
    
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var reduceButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    //MARK: - IBActions
    
    @IBAction func reduceRestButton(_ sender: Any) {
        countdown?.adjustRemainingTime(secondsDelta: -10)
    }
    @IBAction func addRestButton(_ sender: Any) {
        countdown?.adjustRemainingTime(secondsDelta: 10)
    }
    @IBAction func dismissOverlayButton(_ sender: Any) {
        // NAVIGATION
        hide()
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let largeSymbolImage = UIImage(systemName: "minus.circle.fill", withConfiguration: largeConfig)
        reduceButton.setImage(largeSymbolImage, for: .normal)
        let largeAddConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        let largeAddSymbolImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeAddConfig)
        addButton.setImage(largeAddSymbolImage, for: .normal)

        configView()
        countdown = CountdownTimer(time: 60)
        countdown?.start(completion: {
            // NAVIGATION
            self.hide()
        })
        // Timer to update UI label
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                //self.countdownTimer.text = String(self.countdown?.getTimeRemaining() ?? 0)
                self.countdownTimer.text = self.formatter.string(from: TimeInterval(self.countdown?.getTimeRemaining() ?? 0))
            }
        }
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
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
        timer?.invalidate()
        timer = nil
        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseOut) {
            self.contentView.alpha = 0
        } completion: { _ in
            self.navigationController?.popViewController(animated: true)
            self.delegate?.didDismissOverlay()
        }
    }

  

}
