import SwiftUI

struct BaseView: View {
    @State var start: Bool = false
    @State private var selection = 2
   
    @State var showLogin = true
    
    var body: some View {
        if UserDefaults.standard.bool(forKey: "logged") {
            ZStack (alignment: .bottomTrailing) {
                TabView (selection:$selection) {
                    FeedView().tabItem {
                        Text("Feed")
                        Image(systemName: "list.dash")
                    }.tag(1)
                    MainView().tabItem {
                        Text("Tracker")
                        Image(systemName: "hare")
                    }.tag(2)
                    ProfileView().tabItem {
                        Text("Profile")
                        Image(systemName: "person.crop.circle")
                    }.tag(3)
                }
                .accentColor(.red)
            }
            .ignoresSafeArea(.all)
            .fullScreenCover(isPresented: $showLogin) {
                LoginView(showLogin: $showLogin)
            }
        }
    }
    
}
