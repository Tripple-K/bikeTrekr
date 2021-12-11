//
//  SessionSettings.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 17.10.2021.
//

import SwiftUI

struct SessionSettingsView: View {
    @Binding var typeSession: TypeSession
    @Binding var voiceFeedback: Bool
    @Binding var timer: Int
    @State var showPicker: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Text("Training Type")
                Picker("Training Type", selection: $typeSession) {
                    ForEach(TypeSession.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                Toggle("Voice Feedback", isOn: $voiceFeedback)
                Text("Delay start timer \(timer) secs").onTapGesture { showPicker.toggle() }
                CollapsableWheelPicker("Delay start timer \(timer)", showsPicker: $showPicker, selection: $timer) {
                    ForEach(0...10, id: \.self) { i in
                       Text("\(i) secs")
                    }
                }
                
            }
            .accentColor(.red)
            .navigationTitle("Settings")
        }
    }
}



enum TypeSession: String, Equatable, CaseIterable {
    case run = "Run"
    case bike = "Bike"
    case walk = "Walk"
}


