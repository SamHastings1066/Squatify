//
//  RestOverlayViewController.swift
//  Squat Counter
//
//  Created by sam hastings on 18/07/2023.
//

import UIKit

protocol RestOverlayViewControllerDelegate: AnyObject {
    func didDismissOverlay()
}

class RestOverlayViewController: UIViewController {
    
    weak var delegate: RestOverlayViewControllerDelegate?
    var countdown: CountdownTimer?
    let formatter = DateComponentsFormatter()
    
    

    //MARK: - IBOutlets
    
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    //MARK: - IBActions
    
    @IBAction func reduceRestButton(_ sender: Any) {
        countdown?.adjustRemainingTime(secondsDelta: -10)
    }
    @IBAction func addRestButton(_ sender: Any) {
        countdown?.adjustRemainingTime(secondsDelta: 10)
    }
    @IBAction func dismissOverlayButton(_ sender: Any) {
        hide()
    }
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        countdown = CountdownTimer(time: 60)
        countdown?.start(completion: {
            self.hide()
        })
        // Timer to update UI label
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                //self.countdownTimer.text = String(self.countdown?.getTimeRemaining() ?? 0)
                self.countdownTimer.text = self.formatter.string(from: TimeInterval(self.countdown?.getTimeRemaining() ?? 0))
            }
        }
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
    }
    
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
        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseOut) {
            self.contentView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
            self.removeFromParent()
            self.delegate?.didDismissOverlay()
        }
    }

  

}
