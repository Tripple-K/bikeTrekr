


import SwiftUI
import FirebaseAuth
import Charts

struct FeedView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var userInfoVM = UserInfoViewModel()
    
    @State var profileImage = Image("")
    
    @State var period: Period = .weekOfYear
    @State var showProfile = false
    
    @State var loading = true
    
    @State var currSection = 0
    
    
    @ObservedObject var sessionsVM = SessionsViewModel()
    
    var body: some View {
        NavigationView {
            VStack  {
                if sessionsVM.isLoading {
                    ProgressView()
                } else {
                    ScrollView (showsIndicators: false) {
                        
                        VStack (spacing: 16) {
                            VStack (spacing: 0) {
                                Picker("Period", selection: $period) {
                                    ForEach(Period.allCases, id: \.self) {
                                        Text($0.rawValue.capitalized)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                if sessionsVM.isLoading {
                                    ProgressView()
                                } else {
                                    VStack {
                                        SectionPicker(selection: $currSection, sections: $sessionsVM.sections)
                                        
                                        
                                        Text("OVERALL")
                                            .bold()
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                            .padding(.leading)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        
                                        
                                        
                                        Text("\(String(format: "%.2f", sessionsVM.overallDistance).replacingOccurrences(of: ".", with: ",")) km")
                                            .bold()
                                            .font(.largeTitle)
                                            .padding(.leading)
                                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                        
                                        let entries = sessionsVM.getEntries(period)
                                        if entries.count > 1 {
                                            BarChart(entries: sessionsVM.getEntries(period), indexAxisValues: sessionsVM.getIndexAxisValues(period))
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: 175)
                                        }
                                    }
                                    .padding(.vertical)
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                            .padding([.top, .leading, .trailing])
                            
                            
                            ForEach(sessionsVM.sessions) { session in
                                NavigationLink(destination: DetailSessionView(session: session)) {
                                    SessionView(session: session)
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                                        .padding(.horizontal)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                            }
                        }
                        
                        
                    }
                    
                }
                
                
                
            }
            .onReceive(sessionsVM.$isLoading) { _ in
                guard !sessionsVM.isLoading else { return }
                sessionsVM.changePeriod(period)
                currSection = sessionsVM.sections.count - 1
            }
            .onChange(of: period) { _ in
                sessionsVM.changePeriod(period)
                currSection = sessionsVM.sections.count - 1
            }
            .onChange(of: currSection) { _ in
                sessionsVM.changeSection(period, currSection: currSection)
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
            guard let image = image else {
                self.profileImage = Image(systemName: "person.circle.fill")
                return
            }
            self.profileImage = image
        }
        
        .sheet(isPresented: $showProfile) {
            ProfileView(userInfoViewModel: userInfoVM)
        }
    }
}



struct FeedView_Preview: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
