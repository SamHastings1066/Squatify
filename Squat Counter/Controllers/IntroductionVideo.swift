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
        view.backgroundColor = .black // or any other color you prefer
        
        setupVideoPlayer()
        setupInstructionLabel()
        setupStartButton()
    }
    
    func setupVideoPlayer() {
        // Get the video path
        guard let path = Bundle.main.path(forResource: "intro-comp", ofType: "mp4") else { return }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        player?.isMuted = true
        
        // Create the player layer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        
        // Calculate the frame
        let playerLayerHeight = view.bounds.height * 0.8
        playerLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: playerLayerHeight)
        
        // Add the player layer to the view's layer
        view.layer.addSublayer(playerLayer)
        
        // Handle video end
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
        
        // Start the video
        player?.play()
    }
    
    func setupInstructionLabel() {
        let instructionLabel = UILabel()
        instructionLabel.text = "Place your phone in a stable position so that your entire body is visible before you begin squatting"
        instructionLabel.numberOfLines = 0
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        
        // Add to view
        view.addSubview(instructionLabel)
        
        // Disable autoresizing and set constraints
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.65),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func setupStartButton() {
        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Squatting", for: .normal)
        startButton.applyCustomConfiguration()
//        startButton.setTitleColor(.orange, for: .normal)
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
//        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24.0)
        
        // Add to view
        view.addSubview(startButton)
        
        // Disable autoresizing and set constraints
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //startButton.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.8 + 30), // Adjust this constant value to control the gap between label and button
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    
    @objc func startButtonTapped() {
        player?.pause()

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

