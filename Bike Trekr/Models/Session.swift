import SwiftUI
import FirebaseFirestoreSwift
import CoreLocation
import HealthKit

struct Session: Identifiable, Codable {
    @DocumentID var id: String?
    var distance: Double {
        var distance = 0.0
        intervals.forEach {
            distance += $0.distance
        }
        return distance
    }
    var duration: Int = 0
    var date: Date = Date()
    
    var avSpeed: Double {
        return 0
    }

    var maxSpeed: Double {
        return 0
    }

    var goal: GoalType = .none
    var typeSession: SessionType = .running
    var userId: String? = ""
    var intervals = [Interval]()
}

enum SessionType: String, Equatable, CaseIterable, Codable {
    case running, cycling, walking
}

struct Interval: Codable {
    var index: Int = 1
    var distance: Double = 0
    var duration: Int = 0
    
    var locations = [Location]()
}

extension SessionType {
    var activityType: HKWorkoutActivityType {
        switch self {
        case .running: return .running
        case .walking: return .walking
        case .cycling: return .cycling
        }
    }
}

 
