//
//  Stopwatch.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation

class Stopwatch {
    @Published var elapsedTime: Double = 0.0
    private var timer: DispatchSourceTimer?
    private var startTime: DispatchTime?
    private var lastRepTime: DispatchTime?
    private var pauseTime: DispatchTime?
    private var pauseInterval: UInt64 = 0
    
    func start() {
        self.stop()
        self.startTime = DispatchTime.now()
        self.lastRepTime = self.startTime
        self.setupTimer()
    }

    func stop() {
        self.timer?.cancel()
        self.timer = nil
    }

    func reset() {
        self.stop()
        self.startTime = nil
        self.lastRepTime = nil
        self.pauseInterval = 0
        self.pauseTime = nil
    }
    
    func pause() {
        self.pauseTime = DispatchTime.now()
        self.timer?.cancel()
        self.timer = nil
    }
    
    func `continue`() {
        if let pauseTime = self.pauseTime {
            pauseInterval += DispatchTime.now().uptimeNanoseconds - pauseTime.uptimeNanoseconds
        }
        self.pauseTime = nil
        self.setupTimer()
    }
    
    private func setupTimer() {
        self.timer = DispatchSource.makeTimerSource(queue: .global())
        self.timer?.schedule(deadline: .now(), repeating: .seconds(1))
        self.timer?.setEventHandler { [weak self] in
            self?.updateElapsedTime()
        }
        self.timer?.resume()
    }

    func getElapsedTime() -> Double {
            guard let startTime = self.startTime else {
                return 0
            }
            let elapsedNanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds - pauseInterval
            let milliTime = Double(elapsedNanoTime) / 1_000_000
            //self.elapsedTime = milliTime
            return milliTime
    }
    
    func updateElapsedTime() {
            guard let startTime = self.startTime else {
                elapsedTime = 0
                return
            }
            let elapsedNanoTime = DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds - pauseInterval
            let secTime = Double(elapsedNanoTime) / 1_000_000_000
            elapsedTime = secTime
    }
    
    func getRepTime() -> Double {
        guard let lastRepTime = self.lastRepTime else {
            return getElapsedTime()
        }
        let milliTime = Double(DispatchTime.now().uptimeNanoseconds - lastRepTime.uptimeNanoseconds) / 1_000_000
        self.lastRepTime = DispatchTime.now()
        return milliTime
    }
}
