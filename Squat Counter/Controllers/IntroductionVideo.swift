//
//  IntroductionVideo.swift
//  Squat Counter
//
//  Created by sam hastings on 10/08/2023.
//

import UIKit
import AVKit

class IntroductionVideo: UIViewController {
    
    var player: AVPlayer?
    
    // Workout parameters
    var restInterval = 60
    var repTarget = 0
    var setTarget = 0
    var weightOnBar = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        // Configure audio session to allow other audio to mix
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category. Error: \(error)")
        }

        
        // Create a video player
        guard let path = Bundle.main.path(forResource: "intro-comp", ofType: "mp4") else { return }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        player?.isMuted = true
        let playerLayer = AVPlayerLayer(player: player)
        player?.actionAtItemEnd = .none
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.8)
        view.layer.addSublayer(playerLayer)
        
//        // Add a notification for when the video finishes playing
//        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        // Looping observer: return video to start and then ply it again
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        
        // Create a background view for the bottom 20%
        let backgroundView = UIView(frame: CGRect(x: 0, y: view.bounds.height * 0.8, width: view.bounds.width, height: view.bounds.height * 0.2))
        backgroundView.backgroundColor = .black
        view.addSubview(backgroundView)
        
        // Create a label for instructions
        let instructionLabel = UILabel()
        instructionLabel.text = "Place your phone in a stable position so that your entire body is visible before you begin squatting"
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        backgroundView.addSubview(instructionLabel)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 10),
            instructionLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -10),
            instructionLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 0)
        ])
        
        // Create a "Skip" button
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Squatting", for: .normal)
        startButton.setTitleColor(.orange, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        backgroundView.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            startButton.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 10)
        ])
        
        // Start playing the video
        player?.play()
    }
    
//    @objc func videoDidEnd() {
//        navigateToSquatVC()
//    }
    
//    @objc func startButtonTapped() {
//        player?.pause()
//        navigateToSquatVC()
//    }
    
    @objc func startButtonTapped() {
        player?.pause()

        // Create a view to cover the entire screen
        let countdownView = UIView(frame: view.bounds)
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
        
        

//        // Countdown logic
//        var countdownNumber = 5
//        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
//            if countdownNumber == 0 {
//                countdownLabel.text = "GO!"
//            } else if countdownNumber < 0 {
//                timer.invalidate()
//                countdownView.removeFromSuperview()
//                self?.navigateToSquatVC()
//                return
//            } else {
//                countdownLabel.text = "\(countdownNumber)"
//            }
//            countdownNumber -= 1
//        }
//        timer.fire()
        // Start the countdown animation
        animateCountdown(from: 5, label: countdownLabel, completion: { [weak self] in
            countdownView.removeFromSuperview()
            self?.navigateToSquatVC()
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







    
    func navigateToSquatVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let squatVC = storyboard.instantiateViewController(withIdentifier: "SquatVC") as? SquatVC else { return }
        squatVC.repTarget = repTarget
        squatVC.setTarget = setTarget
        squatVC.weightOnBar = weightOnBar
        squatVC.restInterval = restInterval
        
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(squatVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
}

