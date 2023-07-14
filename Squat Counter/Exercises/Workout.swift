//
//  Workout.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation

class Workout {
    var workoutArray: [Rep]

    init(workoutArray: [Rep] = []) {
        self.workoutArray = workoutArray
    }

    func addRep(exercise: String, time: Double, metricValues: [String: Double]) {
        let newRep = Rep(exercise: exercise, time: time, metricValues: metricValues)
        workoutArray.append(newRep)
    }

    func computeWorkoutDuration() -> Double {
        var totalDuration: Double = 0
        for rep in workoutArray {
            totalDuration += rep.time
        }
        return totalDuration
    }
}
