//
//  CountdownTimer.swift
//  Squat Counter
//
//  Created by sam hastings on 19/07/2023.
//

import Foundation

class CountdownTimer {
    private var timer: Timer?
    private var timeRemaining: Int
    private var completionHandler: (() -> Void)?
    
    // The CountdownTimer takes a starting value in seconds
    init(time: Int) {
        self.timeRemaining = time
    }
    
    // This function starts the timer
    func start(completion: @escaping () -> Void) {
        self.completionHandler = completion
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.completionHandler?()
            }
        }
    }
    
    // This function stops the timer
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    // This function adjusts the remaining time
    func adjustRemainingTime(secondsDelta: Int) {
        timeRemaining += secondsDelta
        if timeRemaining < 0 {
            timeRemaining = 0
        }
    }
    
    // This function returns the remaining time
    func getTimeRemaining() -> Int {
        return timeRemaining
    }
}
