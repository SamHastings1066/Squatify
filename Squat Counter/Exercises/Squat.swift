//
//  Squat.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation

class Squat: Exercise {
    init() {
        super.init(
            name: "squat",
            entryConditions: [
                { embedding in return -20 < embedding["leftFemurAngle"]! && embedding["leftFemurAngle"]! < 40 },
                { embedding in return -20 < embedding["rightFemurAngle"]! && embedding["rightFemurAngle"]! < 40 },
                { embedding in return embedding["leftHipAngle"]! < 80 },
                { embedding in return embedding["rightHipAngle"]! < 80 },
                { embedding in return embedding["leftKneeAngle"]! > 81 },
                { embedding in return embedding["rightKneeAngle"]! > 81 }
            ],
            exitConditions: [
                //{ embedding in return embedding["leftFemurAngle"]! > 60 },
                //{ embedding in return embedding["rightFemurAngle"]! > 60 },
                { embedding in return embedding["leftHipAngle"]! > 110 },
                { embedding in return embedding["rightHipAngle"]! > 110 },
                //{ embedding in return embedding["leftKneeAngle"]! < 89 },
                //{ embedding in return embedding["rightKneeAngle"]! < 89 }
            ],
            metricsToMonitor: [
                Metric(
                    name: "minSquatDepth",
                    value: { embeddingDict in return round(embeddingDict["averageFemurAngle"]! * 100) / 100 },
                    //minOrMax: .min
                    minOrMax: "min"
                )
            ]
        )
        self.resetMetrics()
    }
}
