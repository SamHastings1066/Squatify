//
//  Rep.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation
import RealmSwift

struct Rep {
    var exercise: String = ""
    var time: Double = 0.0
    var metricValues: [String: Double] = [:]
}


