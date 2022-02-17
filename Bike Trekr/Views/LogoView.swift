
import SwiftUI

struct LogoView: View {
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var times: Int = 5
    @Binding var showLogoAnimation: Bool
    
    var body: some View {
        withAnimation {
            ZStack {
                Text("Bike Trekr").font(.largeTitle).bold().foregroundColor(.white)
                GIFImage(name: "animation-logo")
            }.background(Color.init("LaunchColor"))
        }.onReceive (timer) { _ in
            if times > 1 {
                times -= 1
            }
            else {
                showLogoAnimation.toggle()
            }
        }
    }
}
