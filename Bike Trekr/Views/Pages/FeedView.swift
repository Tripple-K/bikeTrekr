


import SwiftUI

struct FeedView: View {
    @Binding var showLogin: Bool
    @EnvironmentObject var sessionRepo: SessionRepository
    @EnvironmentObject var auth: AuthenticationService
    var body: some View {
        
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(sessionRepo.sessions) { session in
                        DetailSessionView(session: session).padding()
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .navigationBarTitle("Feed")
            Spacer()
        }
        .frame(alignment: .leading)
        .onAppear {
            if auth.user == nil {
                showLogin = true
            }
            sessionRepo.get()
        }
    }
}

struct FeedView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        FeedView(showLogin: $show)
    }
}
