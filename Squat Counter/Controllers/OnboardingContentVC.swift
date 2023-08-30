//
//  OnboardingVC.swift
//  Squat Counter
//
//  Created by sam hastings on 22/08/2023.
//

import AVFoundation
import UIKit

class OnboardingContentVC: UIViewController {
    var pageIndex: Int = 0
    var titleText: String = ""
    var descriptionText: String?
    var showAccessButton: Bool = false
    var accessButton = UIButton(type: .system)
    // Add other properties as needed
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .black
        
        // Create peach image view
        let peachImageView = UIImageView(image: UIImage(named: "peach"))
        peachImageView.contentMode = .scaleAspectFill
        peachImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the description label is descriptionText is set
        let descriptionLabel = UILabel()
        descriptionLabel.text = descriptionText
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create access button if required
        if showAccessButton {
            accessButton.setTitle("Allow camera access", for: .normal)
            accessButton.applyCustomConfiguration()
            accessButton.addTarget(self, action: #selector(requestCameraAccess), for: .touchUpInside)
        }
        accessButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        self.view.addSubview(peachImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(descriptionLabel)
        
        
        // Set up constraints
        NSLayoutConstraint.activate([
            peachImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            peachImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -40),
            titleLabel.topAnchor.constraint(equalTo: peachImageView.bottomAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            descriptionLabel.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            descriptionLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            //descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            //descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20)
            
        ])
        

        if showAccessButton {
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(spacerView)
            view.addSubview(accessButton)

            // Constraints for the spacerView
            NSLayoutConstraint.activate([
                spacerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
                spacerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                spacerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                spacerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ])

            // Constraints for the accessButton
            NSLayoutConstraint.activate([
                accessButton.centerYAnchor.constraint(equalTo: spacerView.centerYAnchor),
                accessButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ])
        }
    }
    
    @objc func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.accessButton.isEnabled = false
                    self.accessButton.setTitle("Camera access granted", for: .normal)
                } else {
                    self.accessButton.isEnabled = false
                    self.accessButton.setTitle("Camera access not granted", for: .normal)
                }
            }
        }
    }
}

