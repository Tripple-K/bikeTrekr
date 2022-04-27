

import SwiftUI

struct StartUpSessionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var show: Bool
    @Binding var timeBeforeSession: Int
    @State var times = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        withAnimation(.easeOut(duration: 1).speed(2).repeatForever()) {
            VStack {
                Text("\(times)")
                    .font(.custom("Monaco", size: 87)).foregroundColor(.red)
                    .onAppear {
                        times = timeBeforeSession
                    }
                    .onReceive (timer) { _ in
                        if times > 1 {
                            times -= 1
                            generatorHeavy.impactOccurred()
                        }
                        else {
                            self.show.toggle()
                        }
                    }
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                self.show.toggle()
            }
           
        }
    }
}

