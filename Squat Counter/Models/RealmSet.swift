//
//  RealmSet.swift
//  Squat Counter
//
//  Created by sam hastings on 24/07/2023.
//

import Foundation
import RealmSwift

class RealmSet: Object {
    @objc dynamic var setId: String = UUID().uuidString
    @objc dynamic var setNum: Int = 0
    @objc dynamic var numReps: Int = 0
    @objc dynamic var exerciseName: String? = nil
    @objc dynamic var weight: String = "air"
    
    let reps = List<RealmRep>()
    let parentWorkout = LinkingObjects(fromType: RealmWorkout.self, property: "sets")

    override static func primaryKey() -> String? {
        return "setId"
    }
}
