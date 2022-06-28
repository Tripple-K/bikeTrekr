


import SwiftUI
import FirebaseAuth

struct FeedView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var sections = [String]() {
        didSet {
            currSection = sections.count - 1
        }
    }
    @ObservedObject var userInfoVM = UserInfoViewModel()
    
    @State var currSection = 0
    
    @State var profileImage = Image(systemName: "person.circle.fill")
    
    @State var period: Period = .week
    @State var showProfile = false
    
    @State var loading = true
    
    @State var sessions = [Session]()
    
    
    var keysOverallChart: [String] {
        guard let first = sessions.first?.date else { return [] }
        switch period {
        case .week:
            return Calendar.current.shortWeekdaySymbols
        case .month:
            return Calendar.current.range(of: .day, in: .month, for: first)?.compactMap { day -> String in
                return "\(day)"
            } ?? []
        case .year:
            return Calendar.current.shortMonthSymbols
        case .all:
            return sections
        }
    }
    
    var valuesOverallChart: [Double] {
        switch period {
        case .week:
            var values: [Double] = [0..<7].compactMap { _ in return 0.0 }
            
            sessions.forEach { session in
                guard let weekday = session.weekday else { return }
                values[weekday - 1] += session.distance
            }
            
            return values
        case .month:
            
            guard let first = sessions.first, let days = Calendar.current.range(of: .day, in: .month, for: first.date)?.count else { return [] }
            var values: [Double] = [0..<days].compactMap { _ in return 0.0 }
            
            sessions.forEach { session in
                
                guard let monthDay = session.monthDay else { return }
                
                values[monthDay - 1] += session.distance
            }
            return values
        case .year:
//            guard let first = sessions.first else { return [] }
//            var values: [Double] = [0..<12].compactMap { _ in return 0.0 }
//
//            sessions.forEach { session in
//
//            }
//            return values
            return []
            
        case .all:
            return []
        }
    }
    
    
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
                        
                        SectionPicker(selection: $currSection, sections: $sections)
                        
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
                            
//                            OverallChartView(keys: keysOverallChart, values: valuesOverallChart)
                            
                        } .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                    .padding()
                    
                    if SessionRepository.shared.isLoading {
                        ProgressView()
                    } else {
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
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .onReceive(SessionRepository.shared.$sessions) { _ in
                resolve()
            }
            .onChange(of: period) { _ in
                resolve()
            }
            .onChange(of: currSection) { _ in
                resolve()
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showProfile.toggle()
                    }, label: {
                        if StorageImages.shared.isLoading {
                            ProgressView()
                        } else {
                            profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 33, height: 33)
                                .background(Color(uiColor: UIColor.systemFill))
                                .clipShape(Circle())
                        }
                        
                    })
                    .disabled(StorageImages.shared.isLoading)
                    
                    
                }
            }
            .background(Color("background"))
        }
        .onReceive(UserRepository.shared.$userInfo) { userInfo in
            guard let userInfo = userInfo else { return }
            userInfoVM.userInfo = userInfo
            if let image = StorageImages.shared.image {
                self.profileImage = image
            } else {
                StorageImages.shared.download { result in
                    switch result {
                    case .success(let image): self.profileImage = image
                    case .failure(let error): print(error.localizedDescription)
                    }
                }
            }
        }
        .onReceive(StorageImages.shared.$image) { image in
            guard let image = image else { return }
            self.profileImage = image
        }
        
        .sheet(isPresented: $showProfile) {
            ProfileView(userInfoViewModel: userInfoVM)
        }
    }
    
    func resolve() {
        sections = SessionRepository.shared.getPeriods(period)
        sessions = SessionRepository.shared.sessions.filter { session in
            switch period {
            case .week:
                return session.week == sections[currSection]
            case .month:
                return session.month == sections[currSection]
            case .year:
                return session.year == sections[currSection]
            case .all:
                return true
            }
        }
    }
}



