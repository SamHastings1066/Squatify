//
//  GeometricFunctions.swift
//  Squat Counter
//
//  Created by sam hastings on 10/07/2023.
//

import Foundation
import MLKitPoseDetection
import MLKitPoseDetectionCommon
// import SceneKit

func angleWithHorizontal(A: PoseLandmark, B: PoseLandmark) throws -> Double {
    let hypotenuse = calculateDistance(A: A, B: B)
    let vertDistance = B.position.x - A.position.x
    // first, check if the input values are valid
    if (hypotenuse < vertDistance) {
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Invalid input: The hypotenuse should be longer than the vertical distance."])
    }
    // calculate the angle in radians
    let angleInRadians = asin(vertDistance / hypotenuse)

    // convert to degrees
    let angleInDegrees = angleInRadians * (180 / Double.pi)

    return angleInDegrees
}

func calculateDistance(A: PoseLandmark, B: PoseLandmark) -> Double {
    return sqrt(
        pow(A.position.x - B.position.x, 2) +
        pow(A.position.y - B.position.y, 2) +
        pow(A.position.z - B.position.z, 2)
    )
}

func calculateAngle(A: PoseLandmark, B: PoseLandmark, C: PoseLandmark) throws -> Double {
    // Calculates between vectors BA and BC
    let v1 = (x: A.position.x - B.position.x, y: A.position.y - B.position.y, z: A.position.z - B.position.z)
    let v2 = (x: C.position.x - B.position.x, y: C.position.y - B.position.y, z: C.position.z - B.position.z)

    let v1mag = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
    guard v1mag != 0 else {
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Cannot normalize a zero vector"])
    }
    let v1norm = (x: v1.x / v1mag, y: v1.y / v1mag, z: v1.z / v1mag)

    let v2mag = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z)
    guard v2mag != 0 else {
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Cannot normalize a zero vector"])
    }
    let v2norm = (x: v2.x / v2mag, y: v2.y / v2mag, z: v2.z / v2mag)

    let res = v1norm.x * v2norm.x + v1norm.y * v2norm.y + v1norm.z * v2norm.z

    var angle = acos(res)

    // Convert angle from radians to degrees
    angle = angle * 180 / Double.pi

    return angle
}

//func angle(firstLandmark: PoseLandmark,
//           midLandmark: PoseLandmark,
//           lastLandmark: PoseLandmark) throws -> Double {
//    let firstVector = SCNVector3(
//        firstLandmark.position.x - midLandmark.position.x,
//        firstLandmark.position.y - midLandmark.position.y,
//        firstLandmark.position.z - midLandmark.position.z
//    )
//
//    let secondVector = SCNVector3(
//        lastLandmark.position.x - midLandmark.position.x,
//        lastLandmark.position.y - midLandmark.position.y,
//        lastLandmark.position.z - midLandmark.position.z
//    )
//
//    let dotProduct = firstVector.x * secondVector.x + firstVector.y * secondVector.y + firstVector.z * secondVector.z
//
//    let crossProduct = SCNVector3(
//        firstVector.y * secondVector.z - firstVector.z * secondVector.y,
//        firstVector.z * secondVector.x - firstVector.x * secondVector.z,
//        firstVector.x * secondVector.y - firstVector.y * secondVector.x
//    )
//
//    let crossProductMagnitude = sqrt(pow(crossProduct.x, 2) + pow(crossProduct.y, 2) + pow(crossProduct.z, 2))
//
//    let radians = atan2(crossProductMagnitude, dotProduct)
//
//    let degrees = abs(radians * 180.0 / .pi)
//    return Double(degrees)
//}


