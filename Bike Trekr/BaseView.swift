

import SwiftUI

struct BaseView: View {
    @State var showLogoAnimation: Bool = true
    
    var body: some View {
        
        if showLogoAnimation {
            LogoView(showLogoAnimation: $showLogoAnimation)
        } else {
            withAnimation {
                InitialView()
            }
        }
    }
}
