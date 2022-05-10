
import SwiftUI
import Combine
import FirebaseAuth

struct BaseView: View {
    @ObservedObject var auth = AuthenticationService()
    @ObservedObject var userRepo = UserRepository()
    @State var login = Auth.auth().currentUser != nil ? false : true
        
    var body: some View {
        Group {
            if auth.user == nil {
                LoginView()
                    .environmentObject(auth)
            }
            else {
                if let userInfo = userRepo.userInfo {
                    InitialView(userViewModel: UserInfoViewModel(userInfo: userInfo))
                        .environmentObject(auth)
                
                }
            }
        }
        .onReceive(auth.$user) { newValue in
            login = newValue != nil ? false : true
        }
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = .red
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UIDatePicker.appearance().tintColor = .red
        }
    }
}
 
