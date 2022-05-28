

import SwiftUI
import Combine
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfoViewModel: UserInfoViewModel
    @EnvironmentObject var auth: AuthenticationService
    @AppStorage("autoPause") var autoPause = true
    
    @State var showHeightPicker = false
    @State var showWeightPicker = false
    @State var showingAlertLogOut = false 
    @State var editUserName = false
    
    @State var saveable = false
    @State var canceable = true
    
    @State var error = ""
    
    @FocusState var focused: Bool
    
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
            NavigationView {
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
                                            editUserName.toggle()
                                        }
                                        .onChange(of: userInfoViewModel.userInfo.displayName) { newValue in
                                            if newValue.count > 50 {
                                                saveable = false
                                                canceable = false
                                                withAnimation {
                                                    error = "display name is too long"
                                                }
                                            } else if newValue.count < 4 {
                                                saveable = false
                                                canceable = false
                                                withAnimation {
                                                    error = "display name is too short"
                                                }
                                            } else {
                                                saveable = true
                                                canceable = true
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
                                        saveable = true
                                        canceable = true
                                        withAnimation {
                                            error = ""
                                        }
                                        userInfoViewModel.update()
                                    } else {
                                        saveable = false
                                        canceable = false
                                        withAnimation {
                                            error = "your birthday is too young"
                                        }
                                    }
                                }
                            HStack {
                                Text("Height")
                                Spacer()
                                if !showHeightPicker {
                                    Text("\(String(format: "%.1f", userInfoViewModel.userInfo.height)) cm").onTapGesture {
                                        showHeightPicker.toggle()
                                    }
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.red)
                                        .frame(width: 20, height: 20)
                                        .onTapGesture {
                                            showWeightPicker.toggle()
                                        }
                                } else {
                                    TextField("Height", value: $userInfoViewModel.userInfo.height, format: .number).keyboardType(.decimalPad)
                                        .focused($focused)
                                        .multilineTextAlignment(.trailing)
                                        .onChange(of: userInfoViewModel.userInfo.height) { newValue in
                                            if newValue > 300 {
                                                saveable = false
                                                canceable = false
                                                withAnimation {
                                                    error = "height is too long"
                                                }
                                            } else if newValue < 90 {
                                                saveable = false
                                                canceable = false
                                                withAnimation {
                                                    error = "height is too short"
                                                }
                                            } else {
                                                saveable = true
                                                canceable = true
                                                withAnimation {
                                                    error = ""
                                                }
                                                
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
                                    TextField("Weight", value: $userInfoViewModel.userInfo.weight, format: .number).keyboardType(.decimalPad)
                                        .focused($focused)
                                        .multilineTextAlignment(.trailing)
                                        .onChange(of: userInfoViewModel.userInfo.height) { newValue in
                                            if newValue > 300 || newValue < 25 {
                                                saveable = false
                                                canceable = false
                                                withAnimation {
                                                    error = "enter a valid weight"
                                                }
                                            } else {
                                                saveable = true
                                                canceable = true
                                                withAnimation {
                                                    error = ""
                                                }
                                                
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
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button (action: {
                            focused = false
                            showHeightPicker = false
                            showWeightPicker = false
                            editUserName = false
                            userInfoViewModel.update()
                            saveable = false
                        }, label: {
                            Text("Save")
                                .foregroundColor(saveable && userInfoViewModel.isValid ? .red : .gray)
                        })
                        .disabled(!saveable || !userInfoViewModel.isValid)
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button (action: {
                            if !focused && !showHeightPicker && !showWeightPicker && !editUserName {
                                presentationMode.wrappedValue.dismiss()
                            }
                            
                            focused = false
                            showHeightPicker = false
                            showWeightPicker = false
                            editUserName = false
                            
                        }, label: {
                            Text("Cancel")
                                .foregroundColor(canceable && userInfoViewModel.isValid ? .blue : .gray)
                        })
                        .disabled(!canceable && !userInfoViewModel.isValid)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

enum Sex: String, Equatable, CaseIterable, Codable {
    case male, female
}
