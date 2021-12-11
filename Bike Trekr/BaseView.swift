import SwiftUI

struct BaseView: View {
    @State var start: Bool = false
    @State private var selection = 2
    var defaults = UserDefaults.standard
    
    var body: some View {
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
        }.ignoresSafeArea(.all)
//        if defaults.bool(forKey: "logged") {
//
//        } else {
//            LoginView()
//        }
    }
    
}
