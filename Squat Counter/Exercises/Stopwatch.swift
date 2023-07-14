//
//  Stopwatch.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation

class Stopwatch {
    private var timer: DispatchSourceTimer?
    private var startTime: DispatchTime?
    private var lastRepTime: DispatchTime?

    func start() {
        self.stop()
        self.startTime = DispatchTime.now()
        self.lastRepTime = self.startTime
        self.timer = DispatchSource.makeTimerSource(queue: .global())
        self.timer?.schedule(deadline: .now(), repeating: .milliseconds(1))
        self.timer?.resume()
    }

    func stop() {
        self.timer?.cancel()
        self.timer = nil
    }

    func reset() {
        self.stop()
        self.startTime = nil
        self.lastRepTime = nil
    }

    func getElapsedTime() -> Double {
        guard let startTime = self.startTime else {
            return 0
        }
        let milliTime = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000
        return milliTime
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
