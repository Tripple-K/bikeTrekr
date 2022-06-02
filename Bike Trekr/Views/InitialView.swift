import SwiftUI
import FirebaseAuth
import MapKit

struct InitialView: View {
    @State var start: Bool = false
    @AppStorage("page") private var selection = 2
    
    @ObservedObject var userViewModel: UserInfoViewModel
    @ObservedObject var sessionViewModel = SessionViewModel()
    @ObservedObject var sessionRepo = SessionRepository()
    
    var body: some View {
        TabView (selection: $selection) {
            FeedView()
                .environmentObject(userViewModel)
                .tabItem {
                    Text("Feed")
                    Image(systemName: "list.dash")
                }.tag(1)
                .gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                    .onEnded { gesture in
                        let horizontalAmount = gesture.translation.width as CGFloat
                        let verticalAmount = gesture.translation.height as CGFloat
                        
                        if abs(horizontalAmount) > abs(verticalAmount) && horizontalAmount < 0 {
                            
                            selection = 2
                        }
                    }
                )
            MainView()
                .environmentObject(sessionViewModel)
                .tabItem {
                    Text("Tracker")
                    Image(systemName: "hare")
                }.tag(2)
                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { gesture in
                        let horizontalAmount = gesture.translation.width as CGFloat
                        let verticalAmount = gesture.translation.height as CGFloat
                        
                        if abs(horizontalAmount) > abs(verticalAmount) && horizontalAmount > 0 {
                            selection = 1
                        }
                    }
                )
        }
        .accentColor(.red)
        .onAppear {
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            tabBarAppearance.backgroundColor = .clear
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        .onReceive(UserRepository.shared.$userInfo) { _ in
            sessionViewModel.getTemp()
        }
    }
}
