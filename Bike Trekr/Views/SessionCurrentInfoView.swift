import SwiftUI

struct SessionCurrentInfoView: View {
    
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State var showClock = false
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = ""
    
    @AppStorage("goal") var goal: GoalType = .none
    @AppStorage("duration") var seconds: Int = 1800 {
        didSet {
            guard seconds >= 0 else {
                seconds = oldValue
                return
            }
        }
    }
    
    @AppStorage("distance") var distance = 5.0 {
        didSet {
            guard distance >= 0 else {
                distance = oldValue
                return
            }
        }
    }
    
    var duration: String {
        return "\(String(format: "%02d", seconds / 3600)):\(String(format: "%02d", (seconds % 3600) / 60)):\(String(format: "%02d", (seconds % 3600) % 60))"
    }
    
    var remained: String {
        if let from = timeFormatter.date(from: sessionViewModel.duration), let to = timeFormatter.date(from: duration) {
            let diff = Calendar.current.dateComponents([.hour, .minute, .second], from: from, to: to)
            return "\(String(format: "%02d", diff.hour ?? 0)):\(String(format: "%02d", diff.minute ?? 0)):\(String(format: "%02d", diff.second ?? 0))"
        }
        return duration
    }
    
    let timeFormatter = DateFormatter(with: "hh:mm:ss")
    
    let clockFormatter = DateFormatter(with: "hh:mm a")
    
    var body: some View {
        VStack (spacing: 0) {
            VStack {
                HStack {
                    Text("\(sessionViewModel.speed * 3.6 > 0 ? (String(format: "%.1f", sessionViewModel.speed * 3.6)) : "0.0")").font(Font.custom("Monaco", size: 36.0))
                    Text("km/h").font(Font.custom("Monaco", size: 18)).padding(.top, 13)
                }
                Text("speed").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
            }
            VStack {
                HStack {
                    if goal == .distance {
                        Text("\(String(format: "%.2f", distance - sessionViewModel.session.distance))")
                            .font(
                                Font.custom("Monaco", size: 36.0)
                                    .italic())
                            .foregroundColor(.red)
                        
                    } else {
                        Text("\(String(format: "%.2f", sessionViewModel.session.distance))").font(Font.custom("Monaco", size: 36.0).italic())
                    }
                    Text("km").font(Font.custom("Monaco", size: 18.0).italic()).padding(.top, 13)
                    Spacer()
                    Text("\(sessionViewModel.session.avSpeed * 3.6 > 0 ? (String(format: "%.1f", sessionViewModel.session.avSpeed * 3.6)) : "0.0")").font(Font.custom("Monaco", size: 36.0).italic())
                    Text("km/h").font(Font.custom("Monaco", size: 18).italic()).padding(.top, 13)
                }
                .padding(.horizontal)
                HStack {
                    Text("distance").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                    Spacer()
                    Text("av. speed").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                }.padding(.horizontal)
            }
            if goal == .duration {
                Text("\(showClock ? time : remained)".lowercased())
                    .font(Font.custom("Monaco", size: 54.0))
                    .padding(.top)
                    .onTapGesture {
                        showClock.toggle()
                    }
                    .onReceive(timer) { _ in
                        time = clockFormatter.string(from: .now)
                    }
                    .foregroundColor(.red)
            } else {
                Text("\(showClock ? time : sessionViewModel.duration)".lowercased())
                    .font(Font.custom("Monaco", size: 54.0))
                    .padding(.top)
                    .onTapGesture {
                        showClock.toggle()
                    }
                    .onReceive(timer) { _ in
                        time = clockFormatter.string(from: .now)
                    }
            }
        }
    }
}
