//
//  realmRep.swift
//  Squat Counter
//
//  Created by sam hastings on 22/07/2023.
//

import Foundation
import RealmSwift

class RealmRep: Object {
    @Persisted var repId: String = UUID().uuidString
    @Persisted var repNum: Int = 0
    @Persisted var repTime: Double = 0.0
    @Persisted var minSquatDepth: Double = 0.0

    let parentSet = LinkingObjects(fromType: RealmSet.self, property: "reps")

    override static func primaryKey() -> String? {
        return "repId"
    }
}
