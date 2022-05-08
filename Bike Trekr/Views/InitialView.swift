import SwiftUI
import FirebaseAuth

struct InitialView: View {
    @State var start: Bool = false
    @State private var selection = 2
    
    @State var showLogin = Auth.auth().currentUser != nil ? false : true
    
    @ObservedObject var auth = AuthenticationService()
    @ObservedObject var sessionRepo = SessionRepository()
    @ObservedObject var sessionViewModel = SessionViewModel()
    
    @State var hideTabBar = false
    
    var body: some View {
        TabView (selection:$selection) {
            FeedView(showLogin: $showLogin)
                .environmentObject(sessionRepo)
                .environmentObject(auth)
                .tabItem {
                    Text("Feed")
                    Image(systemName: "list.dash")
                }.tag(1)
            MainView(showLogin: $showLogin)
                .environmentObject(sessionRepo)
                .environmentObject(auth)
                .environmentObject(sessionViewModel)
                .tabItem {
                    Text("Tracker")
                    Image(systemName: "hare")
                }.tag(2)
//            RoutesView()
//                .tabItem {
//                    Text("Routes")
//                    Image(systemName: "map.fill")
//                }.tag(3)
        }
        .accentColor(.red)
        .onAppear {
            guard !showLogin else { return }
            
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = .clear
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(showLogin: $showLogin)
        }
    }
}
