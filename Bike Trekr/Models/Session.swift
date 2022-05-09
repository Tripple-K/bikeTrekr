import SwiftUI
import FirebaseFirestoreSwift
import CoreLocation
import HealthKit

struct Session: Identifiable, Codable {
    @DocumentID var id: String?
    var distance: Double = 0
    var duration: String = "00:00:00"
    var date: Date = Date()
    var avSpeed: Double {
        let speeds = locations.compactMap { location -> CLLocationSpeed in
            return location.speed > 0 ? location.speed : 0
        }
        return speeds.reduce(0, +) / Double(locations.count)
    }
    
    var maxSpeed: Double {
        return locations.max(by: {$0.speed < $1.speed})?.speed ?? 0
    }
    var typeSession: SessionType = .running
    var userId: String? = ""
    var locations = [Location]()
}

enum SessionType: String, Equatable, CaseIterable, Codable {
    case running, cycling, walking
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

