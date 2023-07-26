//
//  RealmWorkout.swift
//  Squat Counter
//
//  Created by sam hastings on 24/07/2023.
//

import Foundation
import RealmSwift

class RealmWorkout: Object {
    @objc dynamic var workoutId: String = UUID().uuidString
    @objc dynamic var workoutDate: Date? = nil
    @objc dynamic var startTime: Date? = nil
    @objc dynamic var endTime: Date? = nil

    let sets = List<RealmSet>()

    override static func primaryKey() -> String? {
        return "workoutId"
    }
}
