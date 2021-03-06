


import SwiftUI

struct FeedView: View {

    @EnvironmentObject var auth: AuthenticationService
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var period: Period = .week
    @State var showProfile = false
    
    @State var loading = true
    
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
            .onReceive(SessionRepository.shared.$sessions) { sessions in
                self.sessions = sessions.filter { session in
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
                sessions = SessionRepository.shared.sessions.filter { session in
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
            ProfileView()
                .environmentObject(userInfoViewModel)
        }
    }
}


enum Period: String, Equatable, CaseIterable {
    case week, month, year, all
}
