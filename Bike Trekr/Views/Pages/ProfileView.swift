

import SwiftUI

struct ProfileView: View {
    
    
    @State var showLogin = false
    @EnvironmentObject var auth: AuthenticationService
    @ObservedObject var userRepo = UserRepository()
    @State var birthday = Date()
    @State var newUserName = ""
    @AppStorage("autoPause") var autoPause = true
    
    @State var showHeightPicker = false
    @State var height = 170
    @State var showWeightPicker = false
    @State var weight = 70
    @State var sex: Sex = .male
    @State var showingAlertLogOut = false
    @State var ediUserName = false
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Info").foregroundColor(.red).bold()) {
                    HStack (spacing: 0) {
                        Text("Name")
                        Spacer()
                        if !ediUserName {
                            Text("\(userRepo.user?.displayName ?? "User")").onTapGesture {
                                ediUserName.toggle()
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    ediUserName.toggle()
                                }
                        } else {
                            TextField("\(userRepo.user?.displayName ?? "User")", text: $newUserName)
                                .frame(width: 100, height: 20)
                                .onSubmit {
                                    var user = userRepo.user
                                    user?.displayName = newUserName
                                    user != nil ? userRepo.update(user!) : nil
                                    ediUserName.toggle()
                                }
                        }
                    }
                    .onChange(of: height) { newValue in
                        var user = userRepo.user
                        user?.height = newValue
                        user != nil ? userRepo.update(user!) : nil
                    }
                    DatePicker("Birthday", selection: $birthday, displayedComponents: [.date]).onChange(of: birthday) {newValue in
                        var user = userRepo.user
                        user?.birthday = newValue
                        user != nil ? userRepo.update(user!) : nil
                    }
                    HStack (spacing: 0) {
                        Text("Height")
                        Spacer()
                        Text("\(height) cm").onTapGesture { showHeightPicker.toggle() }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                            .onTapGesture { showHeightPicker.toggle() }
                            .frame(width: 20, height: 20)
                    }
                    .onChange(of: height) { newValue in
                        var user = userRepo.user
                        user?.height = newValue
                        user != nil ? userRepo.update(user!) : nil
                    }
                    CollapsableWheelPicker("Height", showsPicker: $showHeightPicker, selection: $height) {
                        ForEach(91...242, id: \.self) { i in
                            Text("\(i)")
                        }
                    }.onTapGesture { showHeightPicker.toggle() }
                    HStack (spacing: 0) {
                        Text("Weight")
                        Spacer()
                        Text("\(weight)  kg").onTapGesture { showWeightPicker.toggle() }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                            .onTapGesture { showWeightPicker.toggle() }
                            .frame(width: 20, height: 20)
                    }
                    .onChange(of: weight) { newValue in
                        var user = userRepo.user
                        user?.weight = Double(newValue)
                        user != nil ? userRepo.update(user!) : nil
                    }
                    CollapsableWheelPicker("Weight", showsPicker: $showWeightPicker, selection: $weight) {
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
                            var user = userRepo.user
                            user?.sex = newValue.rawValue
                            user != nil ? userRepo.update(user!) : nil
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
            else {
                sex = Sex(rawValue: "\(userRepo.user?.sex ?? "male")")!
                height = userRepo.user?.height ?? 170
                weight = Int(userRepo.user?.weight ?? 70)
                birthday = userRepo.user?.birthday ?? Date()
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
