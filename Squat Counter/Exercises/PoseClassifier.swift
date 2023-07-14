//
//  PoseClassifier.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation


class PoseClassifier {
    var exercises: [Exercise]
    var pose: String
    var poseStartTime: Double?
    var onPoseCompleted: ((String, TimeInterval?, [String: Double]) -> Void)?
    
    init(exercises: [Exercise]) {
        self.exercises = exercises
        self.pose = "neutral"
    }
    
    func updatePose(embeddingDict: [String: Double], stopwatch: Stopwatch? = nil) {
        if self.pose == "neutral" {
            tryEnterPose(embeddingDict: embeddingDict, stopwatch: stopwatch)
        } else {
            tryExitPose(embeddingDict: embeddingDict, stopwatch: stopwatch)
        }
    }
    
    private func tryEnterPose(embeddingDict: [String: Double], stopwatch: Stopwatch?) {
        for exercise in self.exercises {
            guard exercise.isEntryConditionMet(embeddingDict: embeddingDict) else { continue }
            print("ENTERED POSE!")
            self.pose = exercise.name
            self.poseStartTime = stopwatch?.getElapsedTime()
            break
        }
    }
    
    private func tryExitPose(embeddingDict: [String: Double], stopwatch: Stopwatch?) {
        guard let currentExercise = self.exercises.first(where: { $0.name == self.pose }) else { return }
        currentExercise.updateMetrics(embeddingDict: embeddingDict)
        guard currentExercise.isExitConditionMet(embeddingDict: embeddingDict) else { return }
        print("EXITED")
        exitPose(currentExercise: currentExercise, stopwatch: stopwatch)
    }
    
    private func exitPose(currentExercise: Exercise, stopwatch: Stopwatch?) {
        let timeBetweenReps = stopwatch?.getRepTime()
        self.poseStartTime = nil
        onPoseCompleted?(self.pose, timeBetweenReps, currentExercise.metricValues)
        currentExercise.resetMetrics()
        self.pose = "neutral"
    }
    
    func getPose() -> String {
        return self.pose
    }
}


/*
 The onPoseCompleted callback function can be set after initializing the PoseClassifier like this:

let poseClassifier = PoseClassifier(exercises: [Squat()])
poseClassifier.onPoseCompleted = { pose, timeBetweenReps, metricValues in
    // Do something with pose, timeBetweenReps, and metricValues
}
*/
