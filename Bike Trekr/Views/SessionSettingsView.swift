
import SwiftUI

struct SessionSettingsView: View {
    @Binding var typeSession: TypeSession
    @Binding var timer: Int
    @State var showPicker: Bool = false
    @AppStorage("autoPause") var autoPause = true
    
    var body: some View {
        List {
            Section {
                Text("Session Type")
                Picker("Session Type", selection: $typeSession) {
                    ForEach(TypeSession.allCases, id: \.self) {
                        Text($0.rawValue).foregroundColor(.white)
                    }
                }
                .pickerStyle(.segmented)
                Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                Text("Delay start timer \(timer) secs").onTapGesture { showPicker.toggle() }
                CollapsableWheelPicker("Delay start timer \(timer)", showsPicker: $showPicker, selection: $timer) {
                    ForEach(0...10, id: \.self) { i in
                       Text("\(i) secs")
                    }
                }
            }
            .listRowSeparator(.hidden)
            .accentColor(.red)
        }
    }
}



enum TypeSession: String, Equatable, CaseIterable, Codable {
    case run = "Run"
    case bike = "Bike"
    case walk = "Walk"
}


