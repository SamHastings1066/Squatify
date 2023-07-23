//
//  UXUtils.swift
//  Squat Counter
//
//  Created by sam hastings on 14/07/2023.
//
/*
 A File containing functions to help improve the User Experience of the app
 */

import MLKitPoseDetection
import MLKitPoseDetectionCommon

func isBodyVisible(newPose: Pose, threshold: Float = 30.0) -> Bool {
    var totalLikelihood: Float = 0.0
    for landmark in newPose.landmarks {
        totalLikelihood += landmark.inFrameLikelihood
    }
    return totalLikelihood > threshold
}
