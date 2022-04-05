

import SwiftUI

struct ProfileView: View {
    
    
    @State var showLogin = false
    @EnvironmentObject var auth: AuthenticationService
    @ObservedObject var userInfoViewModel: UserInfoViewModel
    @AppStorage("autoPause") var autoPause = true
    
    @State var showHeightPicker = false
    @State var showWeightPicker = false
    @State var showingAlertLogOut = false
    @State var ediUserName = false
    
    @State var sex: Sex = .male
    
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
                    HStack (spacing: 0) {
                        Text("Height")
                        Spacer()
                        Text("\(userInfoViewModel.userInfo.height) cm").onTapGesture { showHeightPicker.toggle() }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                            .onTapGesture { showHeightPicker.toggle() }
                            .frame(width: 20, height: 20)
                    }
                    .onChange(of: userInfoViewModel.userInfo.height) { _ in
                        userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                    }
                    CollapsableWheelPicker("Height", showsPicker: $showHeightPicker, selection: $userInfoViewModel.userInfo.height) {
                        ForEach(91...242, id: \.self) { i in
                            Text("\(i)")
                        }
                    }.onTapGesture { showHeightPicker.toggle() }
                    HStack (spacing: 0) {
                        Text("Weight")
                        Spacer()
                        Text("\(String(format: "%.1f", userInfoViewModel.userInfo.weight))  kg").onTapGesture { showWeightPicker.toggle() }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                            .onTapGesture { showWeightPicker.toggle() }
                            .frame(width: 20, height: 20)
                    }
                    .onChange(of: userInfoViewModel.userInfo.weight) { _ in
                        userInfoViewModel.update(userInfo: userInfoViewModel.userInfo)
                    }
                    CollapsableWheelPicker("Weight", showsPicker: $showWeightPicker, selection: $userInfoViewModel.userInfo.weight) {
                        ForEach(30...500, id: \.self) { i in
                            Text("\(i)")
                        }
                    }.onTapGesture { showWeightPicker.toggle() }
                    HStack {
                        Text("Sex")
                        Spacer()
                        Picker("Sex", selection: $sex) {
                            ForEach(Sex.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }.onChange(of: sex) { newValue in
                            userInfoViewModel.userInfo.sex = newValue.rawValue
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

enum Sex: String, Equatable, CaseIterable {
    case male, female
}
