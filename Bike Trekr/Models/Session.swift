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
    
    var year: String {
        return date.formatted(.dateTime.year())
    }
    
    var month: String {
        return date.formatted(.dateTime.year().month())
    }
    
    var week: String {
        guard let first = date.startOfWeek, let end = date.endOfWeek else { return "" }
        let formatter = DateFormatter(with: "dd.MM")
        return formatter.string(from: first) + "-" + formatter.string(from: end)
    }
    
    var weekOfMonth: String {
        guard let startOfMonth = date.startOfMonth,
            let endOfMonth = date.endOfMonth,
              let startOfWeek = date.startOfWeek,
              let endOfWeek = date.endOfWeek
        else { return "" }
        let formatter = DateFormatter(with: "dd.MM")
        if startOfMonth > startOfWeek  {
            return formatter.string(from: startOfMonth) + "-" + formatter.string(from: endOfWeek)
        } else if endOfWeek > endOfMonth {
            return formatter.string(from: startOfWeek) + "-" + formatter.string(from: endOfMonth)
        } else {
            return formatter.string(from: startOfWeek) + "-" + formatter.string(from: endOfWeek)
        }
    }
    
    var weekday: Int? {
        return Calendar.current.component(.weekday, from: date)
    }
    
    var weekOfYear: Int? {
        return Calendar.current.component(.weekOfYear, from: date)
    }
    
    var intervals = [Interval]()
    
    init (_ session: SessionDefaults) {
        self.date = session.date
        self.goal = session.goal
        self.typeSession = session.typeSession
        self.userId = session.userId
        self.intervals = session.intervals
    }
    
    init () {
        
    }
}

enum SessionType: String, Equatable, CaseIterable, Codable {
    case running, cycling, walking
}

struct Interval: Codable {

    var index: Int = 1
    var distance: Double = 0
    var duration: Int = 0
    
    var speeds = [CLLocationSpeed]()
    
    var avSpeed: Double {
        guard !speeds.isEmpty else { return 0 }
        return speeds.reduce(0, +) / Double(speeds.count)
    }
    
    var maxSpeed: Double {
        return speeds.max() ?? 0
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

 
enum Period: String, Equatable, CaseIterable {
    case weekOfYear = "week", weekOfMonth, month, year, all
    
    static var allCases: [Period] {
        return [.weekOfYear, .month, .year, .all]
    }
}


struct SessionDefaults: Codable {
    let date: Date
    var goal: GoalType
    var typeSession: SessionType
    var userId: String?
    var intervals: [Interval]
    
    init (_ session: Session) {
        self.date = session.date
        self.goal = session.goal
        self.typeSession = session.typeSession
        self.userId = session.userId
        self.intervals = session.intervals
    }
}

