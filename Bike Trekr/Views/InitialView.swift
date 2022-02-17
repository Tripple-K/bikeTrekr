import SwiftUI
import FirebaseAuth

struct InitialView: View {
    @State var start: Bool = false
    @State private var selection = 2

    @State var showLogin = Auth.auth().currentUser != nil ? false : true
    
    @ObservedObject var auth = AuthenticationService()
    
    var body: some View {
        ZStack (alignment: .bottomTrailing) {
            TabView (selection:$selection) {
                FeedView(showLogin: $showLogin).tabItem {
                    Text("Feed")
                    Image(systemName: "list.dash")
                }.tag(1)
                MainView(showLogin: $showLogin).tabItem {
                    Text("Tracker")
                    Image(systemName: "hare")
                }.tag(2)
                    .environmentObject(auth)
                ProfileView(showLogin: $showLogin).tabItem {
                    Text("Profile")
                    Image(systemName: "person.crop.circle")
                }.tag(3)
                    .environmentObject(auth)
            }
            .accentColor(.red)
        }
        .onAppear {
            guard !showLogin else { return }
        }
        .ignoresSafeArea(.all)
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(showLogin: $showLogin)
        }
    }

}
