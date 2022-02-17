//
//  MapView.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 30.09.2021.
//

import SwiftUI

struct FeedView: View {
    
    @Binding var showLogin: Bool
    
    var body: some View {
        SessionsView()
    }
}

struct FeedView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        FeedView(showLogin: $show)
    }
}
