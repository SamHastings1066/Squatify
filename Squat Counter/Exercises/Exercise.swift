//
//  Exercise.swift
//  Squat Counter
//
//  Created by sam hastings on 13/07/2023.
//

import Foundation

class Exercise {
    var name: String
    var entryConditions: [(Dictionary<String, Double>) -> Bool]
    var exitConditions: [(Dictionary<String, Double>) -> Bool]
    var metricsToMonitor: [Metric]
    var metricValues: Dictionary<String, Double>

    init(name: String, entryConditions: [(Dictionary<String, Double>) -> Bool], exitConditions: [(Dictionary<String, Double>) -> Bool], metricsToMonitor: [Metric]) {
        self.name = name
        self.entryConditions = entryConditions
        self.exitConditions = exitConditions
        self.metricsToMonitor = metricsToMonitor
        self.metricValues = Dictionary<String, Double>()
    }

    func resetMetrics() {
        for metric in self.metricsToMonitor {
            self.metricValues[metric.name] = nil
        }
    }

    func updateMetrics(embeddingDict: Dictionary<String, Double>) {
        for metric in self.metricsToMonitor {
            let newValue = metric.value(embeddingDict)
            if (self.metricValues[metric.name] == nil) || (metric.minOrMax == .min && newValue < self.metricValues[metric.name]!) || (metric.minOrMax == .max && newValue > self.metricValues[metric.name]!) {
                self.metricValues[metric.name] = newValue
            }
        }
    }

    func isEntryConditionMet(embeddingDict: Dictionary<String, Double>) -> Bool {
        return self.entryConditions.allSatisfy { $0(embeddingDict) }
    }

    func isExitConditionMet(embeddingDict: Dictionary<String, Double>) -> Bool {
        return self.exitConditions.allSatisfy { $0(embeddingDict) }
    }
}
