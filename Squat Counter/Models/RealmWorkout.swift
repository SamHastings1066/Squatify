//
//  RealmWorkout.swift
//  Squat Counter
//
//  Created by sam hastings on 24/07/2023.
//

import Foundation
import RealmSwift

class RealmWorkout: Object {
    @Persisted(primaryKey: true) var workoutId: String = UUID().uuidString
    @Persisted var workoutDate: Date? = nil
    @Persisted var workoutDay: Int? = nil
    @Persisted var startTime: Date? = nil
    @Persisted var endTime: Date? = nil
    @Persisted var sets = List<RealmSet>()
}
