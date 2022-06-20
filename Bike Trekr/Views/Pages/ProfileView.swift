

import SwiftUI
import Combine
import FirebaseAuth
import PhotosUI

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userInfoViewModel: UserInfoViewModel
    @AppStorage("autoPause") var autoPause = true
    
    @State var showPicker = false
    @State var showingAlertLogOut = false
    @State var showAlertSourcePhoto = false
    @State var showCamera = false
    @State var showLibrary = false
    @State var editUserName = false
    
    @State var profileImage = Image(systemName: "person.circle.fill")
    
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
            
            ScrollView (.vertical, showsIndicators: false) {
                GeometryReader { proxy in
                    let minY = proxy.frame(in: .named("SCROLL")).minY
                    
                    let height = (proxy.size.height + minY)
                    VStack {
                        if !StorageImages.shared.isLoading {
                            profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .background(Color(uiColor: UIColor.systemFill))
                                .clipShape(Circle())
                                .frame(alignment: .center)
                                .padding()
                        } else {
                            ProgressView()
                        }
                        
                        VStack {
                            Text("\(userInfoViewModel.userInfo.displayName)")
                                .bold()
                                .font(.headline)
                            
                            Text("\(userInfoViewModel.userInfo.email)")
                                .bold()
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }.padding()
                        
                        
                    }
                    .frame(width: proxy.size.width, height: height > 60 ? height : 60, alignment: .bottom)
                    .background(height > 60 ? .regularMaterial : .ultraThinMaterial)
                    .cornerRadius(15)
                    .offset(y: -minY)
                    .onTapGesture {
                        showAlertSourcePhoto.toggle()
                    }
                    .confirmationDialog("", isPresented: $showAlertSourcePhoto) {
                        Button("Take a photo") {
                            showCamera.toggle()
                        }
                        
                        Button("Choose a photo") {
                            showLibrary.toggle()
                        }
                        
                    }
                    .sheet(isPresented: $showLibrary) {
                        let configuration: PHPickerConfiguration = {
                            var conf = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                            conf.selectionLimit = 1
                            conf.filter = .images
                            return conf
                        }()
                        ImagePickerView(configuration: configuration, isPresented: $showLibrary) { image in
                            self.profileImage = Image(uiImage: image)
                            guard let data = image.jpegData(compressionQuality: 0) else { return }
                            StorageImages.shared.save(data)
                        }
                        
                    }
                    .sheet(isPresented: $showCamera) {
                        CameraPicker { image in
                            self.profileImage = Image(uiImage: image)
                            guard let data = image.jpegData(compressionQuality: 0) else { return }
                            StorageImages.shared.save(data)
                        }
                    }
                    .onAppear {
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
                }
                .zIndex(1)
                .frame(height: 180)
                
                if error.isEmpty {
                    EmptyView()
                }
                else {
                    Text(error)
                        .padding(.top)
                        .foregroundColor(.red)
                }
                
                infoSection()
                    .padding(.top)
                    .padding()
                services()
                    .padding()
                
                
            }
            .coordinateSpace(name: "SCROLL")
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
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color("background"))
        
    }
    
    @ViewBuilder
    func infoSection() -> some View {
        VStack {
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
                                
                                withAnimation {
                                    error = ""
                                    
                                }
                                
                            }
                            
                        }
                }
                
            }
            .padding(.init(top: 10, leading: 16, bottom: 0, trailing: 16))
            DatePicker("Birthday", selection: $userInfoViewModel.userInfo.birthday, displayedComponents: [.date])
                .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
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
            }
            .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
            .onChange(of: showPicker) { _ in
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
            .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
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
            .padding(.init(top: 8, leading: 16, bottom: 10, trailing: 16))
        }
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color("darkGray"))
        )
    }
    
    @ViewBuilder
    func services() -> some View {
        VStack (alignment: .leading) {
            Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                .padding(.init(top: 10, leading: 16, bottom: 0, trailing: 16))
            Button(action: {
                showingAlertLogOut.toggle()
            }, label: {
                Text("Log Out")
                    .foregroundColor(.red)
                
            }).alert("Are you sure to log out?", isPresented: $showingAlertLogOut) {
                Button("Cancel", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    try? Auth.auth().signOut()
                }
            }
            .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
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
            .padding(.init(top: 8, leading: 16, bottom: 10, trailing: 16))
        }
        .background(RoundedRectangle(cornerRadius: 15)
            .fill(Color("darkGray"))
        )
    }
    
}

enum Sex: String, Equatable, CaseIterable, Codable {
    case male, female
}

enum UserInfoType: String {
    case height, weight
}
