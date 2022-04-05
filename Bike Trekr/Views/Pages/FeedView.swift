


import SwiftUI

struct FeedView: View {
    @Binding var showLogin: Bool
    @EnvironmentObject var sessionRepo: SessionRepository
    @EnvironmentObject var auth: AuthenticationService
    @ObservedObject var userRepo = UserRepository()
    
    @State var showProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView (showsIndicators: false) {
                    ForEach(sessionRepo.sessions) { session in
                        DetailSessionView(session: session)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                            .padding()
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .onAppear {
                if auth.user == nil {
                    showLogin = true
                }
                sessionRepo.get()
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    AsyncImage(url: auth.user?.photoURL, content: { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 33, height: 33)
                        case .failure:
                            Image(systemName: "person.circle.fill").frame(width: 33, height: 33)
                        @unknown default:
                            EmptyView()
                        }
                    })
                        .background(Color(uiColor: UIColor.systemFill))
                        .clipShape(Circle())
                        .onTapGesture {
                            self.showProfile.toggle()
                        }
                }
            }
        }.sheet(isPresented: $showProfile) {
            ProfileView(userInfoViewModel: UserInfoViewModel(userInfo: userRepo.user!))
        }
    }
}


