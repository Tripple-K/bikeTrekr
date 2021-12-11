//
//  StartUpSessionView.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 17.10.2021.
//

import SwiftUI

struct StartUpSessionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var timeBeforeSession: Int
    @State var times = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var scaled = false

    
    var body: some View {
        Text("\(timeBeforeSession)")
            .scaleEffect(scaled ? 0.7 : 1)
            .animation(.easeOut(duration: 1).speed(2).repeatForever())
            .font(.custom("Monaco", size: 87)).foregroundColor(.red)
            .onAppear {
                scaled = true
            }
            .onReceive (timer) { _ in
                if timeBeforeSession > 1 {
                    timeBeforeSession -= 1
                    times += 1
                }
            }
            .onDisappear {
                timeBeforeSession = times + 1
                scaled = false
            }
        
        
    }
}

