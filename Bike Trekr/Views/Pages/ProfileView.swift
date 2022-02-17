//
//  ProfileView.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 30.09.2021.
//

import SwiftUI

struct ProfileView: View {
    
    @Binding var showLogin: Bool
    @EnvironmentObject var auth: AuthenticationService
    @ObservedObject var userRepo = UserRepository()
    @State var birthday = Date()
    @State var statsOn: StatsOnType = .day
    @AppStorage("autoPause") var autoPause = true
    
    @State var showHeightPicker = false
    @State var height = 170
    
    @State var showWeightPicker = false
    @State var weight = 70
    
    @State var sex: Sex = .male
    
    @State var unit: Units = .metric
    
    
    @State var showingAlertLogOut = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Info").foregroundColor(.red).bold()) {
                        DatePicker("Birthday", selection: $birthday, displayedComponents: [.date]).onChange(of: birthday) {newValue in
                            var user = userRepo.user
                            user?.birthday = newValue
                            user != nil ? userRepo.update(user!) : nil
                        }
                        HStack (spacing: 0) {
                            Text("Height")
                            Spacer()
                            Text("\(height) cm").onTapGesture { showHeightPicker.toggle() }
                            Image(systemName: "chevron.right").onTapGesture { showHeightPicker.toggle() }
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
                            Text("\(weight) \(unit == .metric ? "kg" : "lb")").onTapGesture { showWeightPicker.toggle() }
                            Image(systemName: "chevron.right").onTapGesture { showWeightPicker.toggle() }
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
                        
                        
                    }
                    Section(header: Text("Statistics").foregroundColor(.red).bold()) {
                        Picker("Training Type", selection: $statsOn) {
                            ForEach(StatsOnType.allCases, id: \.self) {
                                Text($0.rawValue.capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                        ZStack {
                            Rectangle().fill(Color.clear).blur(radius: 10)
                            Text("no data yet").foregroundColor(.red)
                        }
                       
                    }
                    Section(header: Text("Settings").foregroundColor(.red).bold()) {
                        Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                        HStack {
                            Text("Units")
                            Spacer()
                            Picker("Units", selection: $unit) {
                                ForEach(Units.allCases, id: \.self) {
                                    Text($0.rawValue.capitalized)
                                }
                            }
                            .frame(width: 200)
                            .pickerStyle(.segmented)
                        }
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
                    }
                }
                
                .onAppear {
                    UISegmentedControl.appearance().selectedSegmentTintColor = .red
                    UIDatePicker.appearance().tintColor = .red
                }
                .listStyle(.insetGrouped)
            }
            .background(Color(uiColor: UIColor.systemBackground))
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
            
            .navigationTitle("\(auth.user?.displayName ?? "Profile")")
        }
        
        
    }
}

struct ProfileView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        ProfileView(showLogin: $show)
    }
}

enum StatsOnType: String, Equatable, CaseIterable {
    case day, week, month, year
}

enum Units: String, Equatable, CaseIterable {
    case metric, imperial
}

enum Sex: String, Equatable, CaseIterable {
    case male, female
}
