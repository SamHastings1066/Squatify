//
//  FeatureEmbedder.swift
//  Squat Counter
//
//  Created by sam hastings on 10/07/2023.
//

import MLKitPoseDetection
import MLKitPoseDetectionCommon

class FeatureEmbedder {
    
    var pose: Pose?
    var embeddingDict: [String: Double]?
    
    init() { }
    
    func updatePose(from newPose: Pose) {
        self.pose = newPose
    }

    func updateEmbeddingDict() {
        do {
            embeddingDict = [
                "leftFemurAngle": try self.leftFemurAngle(),
                "rightFemurAngle":  try self.rightFemurAngle(),
                "leftHipAngle":  try self.leftHipAngle(),
                //"leftHipAngleAlt":  try self.leftHipAngleAlt(),
                "rightHipAngle":  try self.rightHipAngle(),
                "leftKneeAngle":  try self.leftKneeAngle(),
                "rightKneeAngle":  try self.rightKneeAngle(),
                "averageFemurAngle": try self.averageFemurAngle(),
            ]
        } catch {
            print("Error calculating embedding: \(error)")
            embeddingDict = nil
        }
    }

    func leftFemurAngle() throws -> Double {
        guard let leftHip = pose?.landmark(ofType: .leftHip),
              let leftKnee = pose?.landmark(ofType: .leftKnee) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
        }
        return try angleWithHorizontal(A: leftHip, B: leftKnee)
    }
    
    func rightFemurAngle() throws -> Double {
        guard let rightHip = pose?.landmark(ofType: .rightHip),
              let rightKnee = pose?.landmark(ofType: .rightKnee) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
        }
        return try angleWithHorizontal(A: rightHip, B: rightKnee)
    }
    
    func averageFemurAngle() throws -> Double {
        let leftAngle = try leftFemurAngle()
        let rightAngle = try rightFemurAngle()
        return (leftAngle + rightAngle) / 2
    }

    func leftHipAngle() throws -> Double {
        guard let leftShoulder = pose?.landmark(ofType: .leftShoulder),
              let leftHip = pose?.landmark(ofType: .leftHip),
              let leftKnee = pose?.landmark(ofType: .leftKnee) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
        }
        return try calculateAngle(A: leftShoulder, B: leftHip, C: leftKnee)
    }
    
//    func leftHipAngleAlt() throws -> Double {
//        guard let leftShoulder = pose?.landmark(ofType: .leftShoulder),
//              let leftHip = pose?.landmark(ofType: .leftHip),
//              let leftKnee = pose?.landmark(ofType: .leftKnee) else {
//            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
//        }
//        return try angle(
//            firstLandmark: leftShoulder,
//            midLandmark: leftHip,
//            lastLandmark: leftKnee)
//    }

    func rightHipAngle() throws -> Double {
        guard let rightShoulder = pose?.landmark(ofType: .rightShoulder),
              let rightHip = pose?.landmark(ofType: .rightHip),
              let rightKnee = pose?.landmark(ofType: .rightKnee) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
        }
        return try calculateAngle(A: rightShoulder, B: rightHip, C: rightKnee)
    }

    func leftKneeAngle() throws -> Double {
        guard let leftHip = pose?.landmark(ofType: .leftHip),
              let leftKnee = pose?.landmark(ofType: .leftKnee),
              let leftAnkle = pose?.landmark(ofType: .leftAnkle) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
        }
        return try 180 - calculateAngle(A: leftHip, B: leftKnee, C: leftAnkle)
    }

    func rightKneeAngle() throws -> Double {
        guard let rightHip = pose?.landmark(ofType: .rightHip),
              let rightKnee = pose?.landmark(ofType: .rightKnee),
              let rightAnkle = pose?.landmark(ofType: .rightAnkle) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid pose landmarks"])
        }
        return try 180 - calculateAngle(A: rightHip, B: rightKnee, C: rightAnkle)
    }

    
}


