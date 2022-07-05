import Combine
import Foundation
import Charts

class SessionsViewModel: ObservableObject {
    @Published var sessions = [Session]()
    @Published var isLoading: Bool = false
    
    var store = Set<AnyCancellable>()
    
    @Published var sections = [String]()
    
    var overallDistance: Double {
        return sessions.reduce(0, {$1.distance + $0})
    }
    
    init () {
        isLoading = true
        SessionRepository.shared.$sessions
            .receive(on: DispatchQueue.main)
            .sink { sessions in
                self.sessions = sessions
                self.isLoading = false
            }
            .store(in: &store)
    }
    
    func getIndexAxisValues(_ period: Period) -> [String] {
        switch period {
            case .weekOfYear:
                return Calendar.current.shortWeekdaySymbols
            case .month:
                return getWeeksOfMonth()
            case .year:
                return Calendar.current.veryShortMonthSymbols
            case .all:
                return SessionRepository.shared.getPeriods(.year)
            case .weekOfMonth:
                return []
        }
    }
    
    func getEntries(_ period: Period) -> [BarChartDataEntry] {
        guard !isLoading, !sessions.isEmpty else { return [] }
        
        switch period {
            case .weekOfYear:
                
                let entries: [BarChartDataEntry] = (0..<7).compactMap { x -> BarChartDataEntry in
                    return BarChartDataEntry(x: Double(x), y: 0)
                }
                
                sessions.forEach { session in
                    guard let weekday = session.weekday else { return }
                    entries[weekday - 1].y += session.distance
                }
                
                return entries
            case .weekOfMonth:
                return []
            case .month:
                let weeks = getWeeksOfMonth()
                
                let entries: [BarChartDataEntry] = (0..<weeks.count).compactMap { x -> BarChartDataEntry in
                    return BarChartDataEntry(x: Double(x), y: 0)
                }
                
                sessions.forEach { session in

                    guard let index = weeks.firstIndex(of: session.weekOfMonth) else { return }
                    entries[index].y += session.distance
                }
                
                return entries
            case .year:
                guard let first = sessions.first?.date, let months = Calendar.current.range(of: .month, in: .year, for: first)?.count else { return [] }
                
                let entries: [BarChartDataEntry] = (0..<months).compactMap { x -> BarChartDataEntry in
                    return BarChartDataEntry(x: Double(x), y: 0)
                }
                
                sessions.forEach { session in
                    let month = Calendar.current.component(.month, from: session.date)
                    entries[month - 1].y += session.distance
                }
                
                return entries
            case .all:
                let years = SessionRepository.shared.getPeriods(.year)
                
                let entries: [BarChartDataEntry] = (0..<years.count).compactMap { x -> BarChartDataEntry in
                    return BarChartDataEntry(x: Double(x), y: 0)
                }
                
                sessions.forEach { session in
                    guard let index = years.firstIndex(of: session.year) else { return }
                    entries[index].y += session.distance
                }
                
                return entries
                
        }
    }
    
    func getWeeksOfMonth() -> [String] {
        guard var first = sessions.first?.date,
              let startOfMonth = first.startOfMonth,
              let endOfMonth = first.endOfMonth else { return [] }
        
        
        guard var weeks = Calendar.current.range(of: .weekOfMonth, in: .month, for: first) else { return [] }
                                                    
        let comps = Calendar.current.dateComponents([.year, .month], from: first)
        
        if let date = Calendar.current.date(from: comps) {
            first = date
        } else { return [] }
        weeks.removeFirst()
        weeks.removeLast()
        
        
        guard let end = first.endOfWeek else { return [] }
        var values = [String]()
        let formatter = DateFormatter(with: "dd.MM")
        
        // first week
        values.append(formatter.string(from: startOfMonth) + "-" + formatter.string(from: end))
        
        if let date = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: first) {
            first = date
        } else { return [] }
        
        
        weeks.forEach { week in
            guard let start = first.startOfWeek, let end = first.endOfWeek else { return }
            values.append(formatter.string(from: start) + "-" + formatter.string(from: end))
            if let date = Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: first) {
                first = date
            } else { return }
        }
        
        
        // last week
        guard let start = first.startOfWeek else { return [] }
        values.append(formatter.string(from: start) + "-" + formatter.string(from: endOfMonth))
        return values
    }
    
    func getPeriods(_ period: Period) -> [String] {
        guard period != .all else { return [] }
        var sections = [String]()
        
        let sessions = sessions.sorted(by: {
            $0.date > $1.date
        })
        
        sessions.forEach {
            switch period {
                case .weekOfYear:
                    sections.contains($0.week) ? nil : sections.append($0.week)
                case .weekOfMonth:
                    sections.contains($0.weekOfMonth) ? nil : sections.append($0.weekOfMonth)
                case .month:
                    sections.contains($0.month) ? nil : sections.append($0.month)
                case .year:
                    sections.contains($0.year) ? nil : sections.append($0.year)
                    
                case .all:
                    break
            }
        }
        return sections.reversed()
    }
    
    func changePeriod(_ period: Period) {
        
        sections = SessionRepository.shared.getPeriods(period)
        sessions = SessionRepository.shared.sessions.filter { session in
            switch period {
                case .weekOfYear:
                    return session.week == sections[sections.count - 1]
                case .weekOfMonth:
                    return session.weekOfMonth == sections[sections.count - 1]
                case .month:
                    return session.month == sections[sections.count - 1]
                case .year:
                    return session.year == sections[sections.count - 1]
                case .all:
                    return true
                    
            }
        }
    }
    
    func changeSection(_ period: Period, currSection: Int) {
        sessions = SessionRepository.shared.sessions.filter { session in
            switch period {
                case .weekOfYear:
                    return session.week == sections[currSection]
                case .weekOfMonth:
                    return session.weekOfMonth == sections[sections.count - 1]
                case .month:
                    return session.month == sections[currSection]
                case .year:
                    return session.year == sections[currSection]
                case .all:
                    return true
            }
        }
    }
}
