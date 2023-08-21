//
//  CountdownTimer.swift
//  Squat Counter
//
//  Created by sam hastings on 19/07/2023.
//

import Foundation

class CountdownTimer {
    private var startTime: Date?
    private var initialTime: Int
    //private var completionHandler: (() -> Void)?
    
    init(time: Int) {
        self.initialTime = time
    }
    
    func start() {
        self.startTime = Date()
    }
    
    func stop() {
        startTime = nil
    }
    
    func adjustRemainingTime(secondsDelta: Int) {
        initialTime += secondsDelta
    }
    
    func getTimeRemaining() -> Int {
        guard let start = startTime else { return initialTime }
        let elapsed = Date().timeIntervalSince(start)
        let remaining = initialTime - Int(elapsed)
        return max(0, remaining)
    }
}
