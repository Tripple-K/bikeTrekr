
import SwiftUI
import HealthKit

struct SessionSettingsView: View {
    @Binding var typeSession: SessionType
    @Binding var timer: Int
    @State var showPicker: Bool = false
    @AppStorage("autoPause") var autoPause = true
    
    var body: some View {
        List {
            Section {
                Text("Session Type")
                Picker("Session Type", selection: $typeSession) {
                    ForEach(SessionType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                Text("Delay start timer \(timer) secs").onTapGesture {
                    withAnimation (.spring()) {
                        showPicker.toggle()
                    }
                }
                CollapsableWheelPicker("Delay start timer \(timer)", showsPicker: $showPicker, selection: $timer) {
                    ForEach(0...10, id: \.self) { i in
                       Text("\(i) secs")
                    }
                }.offset(y: showPicker ? 0 : -100)
            }
            .listRowSeparator(.hidden)
        }
    }
}




