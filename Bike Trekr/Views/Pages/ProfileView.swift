

import SwiftUI
import Combine

struct ProfileView: View {
    @State var showLogin = false
    @EnvironmentObject var auth: AuthenticationService
    @ObservedObject var userInfoViewModel: UserInfoViewModel
    @AppStorage("autoPause") var autoPause = true
    
    @State var showHeightPicker = false
    @State var showWeightPicker = false
    @State var showingAlertLogOut = false
    @State var ediUserName = false
    
    @State var weight = ""
    @State var height = ""

    var body: some View {
        VStack {
            List {
                Section(header: Text("Info").foregroundColor(.red).bold()) {
                    HStack (spacing: 0) {
                        Text("Name")
                        Spacer()
                        if !ediUserName {
                            Text("\(userInfoViewModel.userInfo.displayName)").onTapGesture {
                                ediUserName.toggle()
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    ediUserName.toggle()
                                }
                        } else {
                            TextField("\(userInfoViewModel.userInfo.displayName)", text: $userInfoViewModel.userInfo.displayName)
                                .frame(width: 100, height: 20)
                                .onSubmit {
                                    ediUserName.toggle()
                                    userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                                }
                        }
                    }
                    DatePicker("Birthday", selection: $userInfoViewModel.userInfo.birthday, displayedComponents: [.date]).onChange(of: userInfoViewModel.userInfo.birthday) { _ in
                        userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                    }
                    HStack {
                        Text("Height")
                        Spacer()
                        if !showHeightPicker {
                            Text("\(userInfoViewModel.userInfo.height) cm").onTapGesture {
                                showHeightPicker.toggle()
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    showWeightPicker.toggle()
                                }
                        } else {
                            TextField("Height", text: $height).keyboardType(.numberPad)
                                .frame(width: 100, height: 20)
                                .onSubmit {
                                    if let height = Int(height) {
                                        userInfoViewModel.userInfo.height = height
                                        userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                                        showHeightPicker.toggle()
                                    }
                                }
                                .onReceive(Just(height)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        self.height = filtered
                                    }
                                }
                        }
                    }
                    HStack {
                        Text("Weight")
                        Spacer()
                        if !showWeightPicker {
                            Text("\(String(format: "%.1f", userInfoViewModel.userInfo.weight)) kg").onTapGesture {
                                showWeightPicker.toggle()
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    showWeightPicker.toggle()
                                }
                        } else {
                            TextField("Weight", text: $weight).keyboardType(.decimalPad)
                                .frame(width: 100, height: 20)
                                .onSubmit {
                                    if let weight = Double(weight) {
                                        userInfoViewModel.userInfo.weight = weight
                                        userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                                        showWeightPicker.toggle()
                                    }
                                }
                                .onReceive(Just(weight)) { newValue in
                                    let filtered = newValue.filter { "0123456789.".contains($0) }
                                    if filtered != newValue {
                                        self.weight = filtered
                                    }
                                }
                        }
                    }
                   
                
                    HStack {
                        Text("Sex")
                        Spacer()
                        Picker("Sex", selection: $userInfoViewModel.userInfo.sex) {
                            ForEach(Sex.allCases, id: \.self) {
                                Text($0.rawValue).foregroundColor(.white)
                            }
                        }.onChange(of: userInfoViewModel.userInfo.sex) { newValue in
                            userInfoViewModel.userInfo.sex = newValue
                            userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                        }
                        .frame(width: 150)
                        .pickerStyle(.segmented)
                    }
                    
                    
                }.listRowSeparator(.hidden)
                Section(header: Text("Settings").foregroundColor(.red).bold()) {
                    Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                    Text("Log Out")
                        .foregroundColor(.red)
                        .onTapGesture {
                            showingAlertLogOut.toggle()
                        }
                        .alert("Are you sure to log out?", isPresented: $showingAlertLogOut) {
                            Button("Cancel", role: .cancel) { }
                            Button("Yes", role: .destructive) {
                                auth.logOut()
                                showLogin = true
                            }
                        }
                }.listRowSeparator(.hidden)
            }
            .onAppear {
                UISegmentedControl.appearance().selectedSegmentTintColor = .red
                UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
                UIDatePicker.appearance().tintColor = .red
            }
            .listStyle(.insetGrouped)
        }
        .onAppear {
            if auth.user == nil {
                showLogin = true
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(showLogin: $showLogin)
        }
    }
}

enum Sex: String, Equatable, CaseIterable, Codable {
    case male, female
}
