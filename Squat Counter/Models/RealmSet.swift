//
//  RealmSet.swift
//  Squat Counter
//
//  Created by sam hastings on 24/07/2023.
//

import Foundation
import RealmSwift


class RealmSet: Object {
    @Persisted(primaryKey: true) var setId: String = UUID().uuidString
    @Persisted var setNum: Int = 0
    @Persisted var numReps: Int = 0
    @Persisted var hasBeenEditted: Bool = false
    @Persisted var exerciseName: String? = nil
    @Persisted var weight: String = "air"
    @Persisted var weightLbs: Int = 0
    @Persisted var reps = List<RealmRep>()
    @Persisted(originProperty: "sets") var parentWorkout: LinkingObjects<RealmWorkout>
}
