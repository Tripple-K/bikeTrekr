

import SwiftUI
import Combine
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @EnvironmentObject var auth: AuthenticationService
    @AppStorage("autoPause") var autoPause = true
    
    @State var showPicker: Bool = false
    @State var showingAlertLogOut = false 
    @State var editUserName = false
    
    @State var editType: UserInfoType = .height
    
    @FocusState var focused: Bool
    
    @State var saveable = true
    @State var error: String = ""
    
    var authorizationStatus: String {
        switch HealthAssistant.shared.getAuthorizationStatus() {
        case .sharingAuthorized:
            return "Connected Health App"
        default:
            return "Connect Health App"
        }
    }

    var body: some View {
        
        VStack {
            if error.isEmpty {
                EmptyView()
            }
            else {
                Text(error)
                    .padding(.top)
                    .foregroundColor(.red)
            }
            List {
                Section(header: Text("Info").foregroundColor(.red).bold()) {
                    HStack (spacing: 0) {
                        Text("Name")
                        Spacer()
                        if !editUserName {
                            Text("\(userInfoViewModel.userInfo.displayName)").onTapGesture {
                                editUserName.toggle()
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.red)
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    editUserName.toggle()
                                }
                        } else {
                            TextField("Name", text: $userInfoViewModel.userInfo.displayName)
                                .focused($focused)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: .infinity)
                                .onSubmit {
                                    userInfoViewModel.update()
                                    editUserName.toggle()
                                }
                                .onChange(of: userInfoViewModel.userInfo.displayName) { newValue in
                                    if newValue.count > 50 {
                                        withAnimation {
                                            error = "display name is too long"
                                        }
                                    } else if newValue.count < 4 {
                                        withAnimation {
                                            error = "display name is too short"
                                
                                        }
                                    } else {
                                        focused.toggle()
                                    
                                        withAnimation {
                                            error = ""
                                        
                                        }
                                        
                                    }
                                    
                                }
                        }
                        
                    }
                    DatePicker("Birthday", selection: $userInfoViewModel.userInfo.birthday, displayedComponents: [.date])
                        .onChange(of: userInfoViewModel.userInfo.birthday) { newValue in
                            let age = Calendar.current.dateComponents([.year], from: newValue, to: .now)
                            if age.year ?? 0 >= 16 {
                                withAnimation {
                                    error = ""
                                }
                                userInfoViewModel.update()
                            } else {
                                withAnimation {
                                    error = "Your're too young"
                                }
                            }
                        }
                    HStack {
                        Text("Height")
                        Spacer()
                        Text("\(String(format: "%.1f", userInfoViewModel.userInfo.height)) cm").onTapGesture {
                            withAnimation {
                                showPicker.toggle()
                            }
                            editType = .height
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                withAnimation {
                                    showPicker.toggle()
                                }
                                editType = .height
                            }
                    }.onChange(of: showPicker) { _ in
                        guard editType == .height else { return }
                        if userInfoViewModel.userInfo.height > 300 || userInfoViewModel.userInfo.height < 90 {
                            withAnimation {
                                error = "height is not valid"
                            }
                        } else {
                            userInfoViewModel.update()
                            withAnimation {
                                error = ""
                            }
                        }
                    }
                    .onChange(of: userInfoViewModel.userInfo.height) { _ in
                        if userInfoViewModel.userInfo.height > 300 || userInfoViewModel.userInfo.height < 90 {
                            withAnimation {
                                error = "height is not valid"
                                saveable = false
                            }
                        } else {
                            withAnimation {
                                error = ""
                                saveable = true
                            }
                        }
                    }
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        Text("\(String(format: "%.1f", userInfoViewModel.userInfo.weight)) kg")
                            .onTapGesture {
                                withAnimation {
                                    showPicker.toggle()
                                }
                                editType = .weight
                        }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.red)
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                withAnimation {
                                    showPicker.toggle()
                                }
                                editType = .weight
                            }
                    }
                    .onChange(of: showPicker) { _ in
                        guard editType == .weight else { return }
                        if userInfoViewModel.userInfo.weight > 300 || userInfoViewModel.userInfo.weight < 25 {
                            withAnimation {
                                error = "weight is not valid"
                            }
                        } else {
                            userInfoViewModel.update()
                            withAnimation {
                                error = ""
                            }
                            
                        }
                        
                    }
                    .onChange(of: userInfoViewModel.userInfo.weight) { _ in
                        if userInfoViewModel.userInfo.weight > 300 || userInfoViewModel.userInfo.weight < 25 {
                            withAnimation {
                                error = "weight is not valid"
                                saveable = false
                            }
                        } else {
                            
                            withAnimation {
                                error = ""
                                saveable = true
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
                        }
                        .frame(width: 150)
                        .pickerStyle(.segmented)
                    }
                    
                    
                }.listRowSeparator(.hidden)
                Section(header: Text("Settings").foregroundColor(.red).bold()) {
                    Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                    Button(action: {
                        showingAlertLogOut.toggle()
                    }, label: {
                        Text("Log Out")
                            .foregroundColor(.red)
                            
                    }).alert("Are you sure to log out?", isPresented: $showingAlertLogOut) {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes", role: .destructive) {
                            auth.logOut()
                        }
                    }
                    Button(action: {
                        switch HealthAssistant.shared.getAuthorizationStatus() {
                        case .sharingAuthorized:
                            break
                        default:
                            HealthAssistant.shared.requestAuthorization()
                        }
                    }, label: {
                        Text(authorizationStatus)
                            .foregroundColor(.green)
                    
                    })
                }.listRowSeparator(.hidden)
            }
            .listStyle(.insetGrouped)
            if showPicker {
                VStack {
                    switch editType {
                    case .height:
                        FastForwardPicker(title: "Height", value: $userInfoViewModel.userInfo.height, diff: 0.5, valueInterpolation: String(format: "%.1f", userInfoViewModel.userInfo.height))
                    case .weight:
                        FastForwardPicker(title: "Weight", value: $userInfoViewModel.userInfo.weight, diff: 0.5, valueInterpolation: String(format: "%.1f", userInfoViewModel.userInfo.weight))
                    }
                    
                    Button(action: {
                        withAnimation {
                            self.showPicker.toggle()
                        }
                    }, label: {
                        Text("Save")
                            .foregroundColor(saveable ? .red : .gray)
                            .bold()
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                    })
                    .padding(5)
                    .disabled(!saveable)
                }
                .offset(y: showPicker ? 0 : 300)
            }
        }
        
    }
}

enum Sex: String, Equatable, CaseIterable, Codable {
    case male, female
}

enum UserInfoType: String {
    case height, weight
}
