//
//  Bike_TrekrApp.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 27.09.2021.
//

import SwiftUI
import Firebase

@main
struct Bike_TrekrApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            BaseView()
        }
    }
}
