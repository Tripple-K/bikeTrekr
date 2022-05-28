import SwiftUI

struct SessionCurrentInfoView: View {
    
    @EnvironmentObject var sessionViewModel: SessionViewModel
    @State var showClock = false
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time = ""
    
    var dateFormatter = DateFormatter(with: "hh:mm a")
    
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
                    Text("\(String(format: "%.2f", sessionViewModel.session.distance))").font(Font.custom("Monaco", size: 36.0).italic())
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
            Text("\(showClock ? time : sessionViewModel.duration)".lowercased())
                .font(Font.custom("Monaco", size: 54.0))
                .padding(.top)
                .onTapGesture {
                    showClock.toggle()
                }
                .onReceive(timer) { _ in
                    time = dateFormatter.string(from: .now)
                }
        }
    }
}
