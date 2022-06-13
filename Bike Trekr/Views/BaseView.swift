
import SwiftUI
import Combine
import FirebaseAuth

struct BaseView: View {
    @ObservedObject var auth = AuthenticationService()
        
    var body: some View {
        Group {
            if auth.user == nil {
                LoginView()
            }
            else {
                InitialView()
            }
        }
    }
}
 
