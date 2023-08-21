//
//  SquatsNC.swift
//  Squat Counter
//
//  Created by sam hastings on 08/08/2023.
//

import UIKit

class SquatsNC: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startWorkoutTV = StartWorkoutTV()
        viewControllers = [startWorkoutTV]
    }
}

