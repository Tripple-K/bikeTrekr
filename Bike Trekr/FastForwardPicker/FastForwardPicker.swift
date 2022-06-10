

import SwiftUI

struct FastForwardPicker<T>: View where T: Numeric {
    
    @State var isLongPress = false
    @State var timer: Timer?
    
    @State var title: String
    
    @GestureState var tap = false
    
    @Binding var value: T {
        didSet {
            guard value as? Double ?? 0 >= 0 else {
                value = oldValue
                return
            }
        }
    }
    
    @State var timeInterval: Double = 1

    let diff: T
    
    var valueInterpolation: String
    
    let generatorLight = UIImpactFeedbackGenerator(style: .soft)
    
    
    
    
    var body: some View {
        VStack {
            Text(title).foregroundColor(.gray).bold()
            HStack {
                Button (action: {
                    if self.isLongPress {
                        timeInterval = 1
                        self.isLongPress.toggle()
                        self.timer?.invalidate()
                    } else {
                        value -= diff
                    }
                    generatorLight.impactOccurred()
                }, label: {
                    Image(systemName: "minus.square")
                        .font(.title)
                })
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                    self.isLongPress = true
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
                        timeInterval += 0.1
                        let multiplier = T(exactly: Int(timeInterval))!
                        self.value -= diff * multiplier
                    }
                })
                .foregroundColor(.red)
                Text("\(valueInterpolation)")
                    .font(.title2)
                Button (action: {
                    if self.isLongPress {
                        timeInterval = 1
                        self.isLongPress.toggle()
                        self.timer?.invalidate()
                    } else {
                        value += diff
                    }
                    generatorLight.impactOccurred()
                }, label: {
                    Image(systemName: "plus.app")
                        .font(.title)
                })
                .simultaneousGesture(LongPressGesture(minimumDuration: 0.2).onEnded { _ in
                    self.isLongPress = true
                    self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
                        timeInterval += 0.1
                        let multiplier = T(exactly: Int(timeInterval))!
                        self.value += diff * multiplier
                    }
                })
                .foregroundColor(.red)
            }
        }
    }
    
}
