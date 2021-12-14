
import SwiftUI
import SwiftUIFontIcon
import FirebaseAuth

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var showLogin: Bool
    
   
    var body: some View {
        VStack {
            Spacer()
            Text("Bike Trekr").font(.largeTitle).bold()
            Spacer()
            Spacer()
            Button(action: {
                if Auth.auth().currentUser != nil {
                    showLogin = false
                } else {
                    GitHub.shared.processLogin()
                }
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

