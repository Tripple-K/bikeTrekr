
import SwiftUI

class StopWatchManager: ObservableObject{
    
    @Published var secondsElapsed = "00:00:00"
    
    var startTime: Date = Date()
    var elapsedTime = 0.0
    var paused = false
    var running = false

    var timer = Timer()
    
    func startWatch(){
        guard !running else { return }
        
        if paused {
            startTime = Date().addingTimeInterval(-elapsedTime)
        } else {
            startTime = Date()
        }
        paused = false
        running = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            let current = Date()
            let diffComponents = Calendar.current.dateComponents([.second], from: self.startTime, to: current)
            let seconds = (diffComponents.second ?? 0)
            self.secondsElapsed = "\(String(format: "%02d", seconds / 3600)):\(String(format: "%02d", (seconds % 3600) / 60)):\(String(format: "%02d", (seconds % 3600) % 60))"
        }
        
    }
    
    func pauseWatch(){
        guard !paused else { return }
        
        timer.invalidate()
        elapsedTime = Date().timeIntervalSince(startTime)
        paused = true
        running = false
    }
    
    func reset() {
        timer.invalidate()
        paused = false
        running = false
        self.secondsElapsed = "00:00:00"
    }

}
