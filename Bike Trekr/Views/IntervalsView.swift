

import SwiftUI

struct IntervalsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var sessionVM: SessionViewModel
     
    var body: some View {
        List {
            HStack {
                Text("").frame(width: 40)
                Text("Distance").frame(width: 80, alignment: .leading)
                Text("Speed").frame(alignment: .leading)
                Spacer()
                Text("Time")
            }
            ForEach(0..<sessionVM.session.intervals.count, id: \.self) { index in
                let interval = sessionVM.session.intervals[index]
                HStack {
                    Text("\(interval.index)").frame(width: 40)
                    Text("\(String(format: "%.1f", interval.distance)) km").frame(width: 80, alignment: .leading)
                    
                    Text("\(String(format: "%.2f", interval.avSpeed)) km/h").frame(alignment: .leading)
                    Spacer()
                    Text("\(String(format: "%02d", interval.duration / 3600)):\(String(format: "%02d", (interval.duration % 3600) / 60)):\(String(format: "%02d", (interval.duration % 3600) % 60))")
                }
            }

        }.onAppear {
            UITableView.appearance().backgroundColor = UIColor.clear
            
        }
    }
}

struct Intervals_View_Previews: PreviewProvider {
    static var previews: some View {
        IntervalsView()
    }
}
