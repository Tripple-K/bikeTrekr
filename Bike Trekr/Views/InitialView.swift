import SwiftUI
import FirebaseAuth
import MapKit

struct InitialView: View {
    @State var start: Bool = false
    @AppStorage("page") private var selection = 2

    var body: some View {
        TabView (selection: $selection) {
            FeedView()
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
            
            UISegmentedControl.appearance().selectedSegmentTintColor = .red
            UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
            UIDatePicker.appearance().tintColor = .red
        }
    }
}
