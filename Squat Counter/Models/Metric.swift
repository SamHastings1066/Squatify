//
//  Metric.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation

struct Metric {
    var name: String
    var value: (Dictionary<String, Double>) -> Double
    //var minOrMax: MetricType
    var minOrMax: String
}

enum MetricType {
    case min, max
}


