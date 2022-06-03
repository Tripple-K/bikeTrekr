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
    var duration: Int {
        var duration = 0
        intervals.forEach {
            duration += $0.duration
        }
        return duration
    }
    var date: Date = Date()
    
    var avSpeed: Double {
        var speeds = 0.0
        
        intervals.forEach {
            speeds += $0.avSpeed
        }
        guard !intervals.isEmpty else { return 0 }
        return speeds / Double(intervals.count)
    }

    var maxSpeed: Double {
        return intervals.max(by: {$0.maxSpeed < $1.maxSpeed})?.maxSpeed ?? 0
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
    
    var avSpeed: Double {
        let speeds = locations.compactMap { location -> CLLocationSpeed in
            return location.speed > 0 ? location.speed : 0
        }
        guard !locations.isEmpty else { return 0 }
        return speeds.reduce(0, +) / Double(locations.count)
    }
    
    var maxSpeed: Double {
        return locations.max(by: {$0.speed < $1.speed})?.speed ?? 0
    }
    
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

 
