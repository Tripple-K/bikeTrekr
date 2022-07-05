import Foundation

extension Date {
    var startOfWeek: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    var endOfWeek: Date? {
        let calendar = Calendar.current
        guard let firstDay = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)) else { return nil }
        return calendar.date(byAdding: .day, value: 6, to: firstDay)
    }
    
    var startOfMonth: Date? {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))
    }
    
    var endOfMonth: Date? {
        guard let startOfMonth = startOfMonth else {
            return nil
        }
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
    }
}
