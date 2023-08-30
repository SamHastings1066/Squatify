//
//  UIButtonConfiguration.swift
//  Squat Counter
//
//  Created by sam hastings on 23/08/2023.
//

import UIKit

extension UIButton {
    
    func applyCustomConfiguration() {
        self.setTitleColor(.orange, for: .normal)
        
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .capsule
        config.buttonSize = .large
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.boldSystemFont(ofSize: 24.0)
            return outgoing
        }
        
        self.configuration = config
    }
}
