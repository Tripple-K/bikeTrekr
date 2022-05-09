


import SwiftUI

struct FeedView: View {
    @Binding var showLogin: Bool
    @EnvironmentObject var sessionRepo: SessionRepository
    @EnvironmentObject var auth: AuthenticationService
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var userRepo = UserRepository()
    
    @State var period: Period = .week
    @State var showProfile = false
    
    @State var sessions: [Session] = []
    
    var body: some View {
        NavigationView {
            VStack {
                
                ScrollView (showsIndicators: false) {
                    
                    VStack {
                        
                        Picker("Period", selection: $period) {
                            ForEach(Period.allCases, id: \.self) {
                                Text($0.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        VStack (alignment: .leading) {
                            
                            Text("OVERALL")
                                .bold()
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.leading)
                            
                            Text("\(String(format: "%.2f", sessions.reduce(0, {$1.distance + $0})).replacingOccurrences(of: ".", with: ",")) km")
                                .bold()
                                .font(.largeTitle)
                                .padding(.leading)
                            
                        } .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                    .padding()
                    
                    Text("RECENT")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, -16)
                        .padding(.leading)
                    ForEach(sessions) { session in
                        NavigationLink(destination: DetailSessionView(session: session)) {
                            SessionView(session: session)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                                .padding()
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = .red
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                
                if auth.user == nil {
                    showLogin = true
                }
                sessionRepo.get()
                sessions = sessionRepo.sessions.filter { session in
                    var filterDate: Date? = Date()
                    switch period {
                    case .week:
                        filterDate = Calendar.current.date(byAdding: .day, value: -7, to: filterDate!)
                    case .month:
                        filterDate = Calendar.current.date(byAdding: .month, value: -1, to: filterDate!)
                    case .year:
                        filterDate = Calendar.current.date(byAdding: .year, value: -1, to: filterDate!)
                    case .all:
                        return true
                    }
                    guard let filterDate = filterDate else {
                        return false
                    }
                    return session.date > filterDate
                }
                
            }
            .onChange(of: period) { newValue in
                sessions = sessionRepo.sessions.filter { session in
                    var filterDate: Date? = Date()
                    switch period {
                    case .week:
                        filterDate = Calendar.current.date(byAdding: .day, value: -7, to: filterDate!)
                    case .month:
                        filterDate = Calendar.current.date(byAdding: .month, value: -1, to: filterDate!)
                    case .year:
                        filterDate = Calendar.current.date(byAdding: .year, value: -1, to: filterDate!)
                    case .all:
                        return true
                    }
                    guard let filterDate = filterDate else {
                        return false
                    }
                    return session.date > filterDate
                }
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showProfile.toggle()
                    }, label: {
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
                    })
                   
                        
                }
            }
            .background(Color("background"))
        }
        .sheet(isPresented: $showProfile) {
            if let user = userRepo.user {
                ProfileView(userInfoViewModel: UserInfoViewModel(userInfo: user))
            }
        }
    }
}


enum Period: String, Equatable, CaseIterable {
    case week, month, year, all
}
