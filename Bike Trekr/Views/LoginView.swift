//
//  LoginView.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 09.11.2021.
//

import SwiftUI
import SwiftUIFontIcon

struct LoginView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Bike Trekr").font(.largeTitle).bold()
            Spacer()
            Spacer()
            Button(action: {
                
            }) {
                FontIcon.text(.ionicon(code: .logo_github), fontsize: 20)
                    .padding([.top, .leading, .bottom])
                
                Text("Sign up with GitHub")
                    .padding([.top, .bottom, .trailing])
                
            }
            .background(Color.red)
            .cornerRadius(10)
            .foregroundColor(.white)
            .padding(.all)
        }
        
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
