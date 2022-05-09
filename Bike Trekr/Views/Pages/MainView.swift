import SwiftUI
import MapKit
import SwiftUIFontIcon

struct MainView: View {
    
    @Binding var showLogin: Bool
    
    @EnvironmentObject var sessionRepo: SessionRepository
    @EnvironmentObject var auth: AuthenticationService
    
    @EnvironmentObject var sessionViewModel: SessionViewModel
    
    let generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let generatorLight = UIImpactFeedbackGenerator(style: .light)
    
    let gradientColors: [Color] = [.clear, .clear.opacity(0.5), .black.opacity(0.7), .black, .black, .black.opacity(0.7), .clear.opacity(0.5), .clear]
    @State var opacity: Double = 0
    
    @State var checkSpeed = 0
    
    @State var showSessionSetUp: Bool = false
    
    @State var scaleStopButton = 1.0
    
    @State var showOverlayBeforeSession = false
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var time = ""
    
    var dateFormatter: DateFormatter {
        let fmtr = DateFormatter()
        fmtr.dateFormat = "hh:mm a"
        return fmtr
    }
    
    @State var showAlertLocationNeeded = false
    
    @State var showClock = false
    
    @AppStorage("autoPause") var autoPause = true
    
    @AppStorage("timerBeforeSession") var timerBeforeSession: Int = 3
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                VStack {
                    HStack {
                        Text("\(sessionViewModel.speed * 3.6 > 0 ? (String(format: "%.1f", sessionViewModel.speed * 3.6)) : "0.0")").font(Font.custom("Monaco", size: 36.0))
                        Text("km/h").font(Font.custom("Monaco", size: 18)).padding(.top, 13)
                    }
                    Text("speed").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                }
                VStack {
                    HStack {
                        Text("\(String(format: "%.2f", sessionViewModel.session.distance))").font(Font.custom("Monaco", size: 36.0).italic())
                        Text("km").font(Font.custom("Monaco", size: 18.0).italic()).padding(.top, 13)
                        Spacer()
                        Text("\(sessionViewModel.session.avSpeed * 3.6 > 0 ? (String(format: "%.1f", sessionViewModel.session.avSpeed * 3.6)) : "0.0")").font(Font.custom("Monaco", size: 36.0).italic())
                        Text("km/h").font(Font.custom("Monaco", size: 18).italic()).padding(.top, 13)
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("distance").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                        Spacer()
                        Text("av. speed").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                    }.padding(.horizontal)
                }
                Text("\(showClock ? time : sessionViewModel.session.duration)".lowercased())
                    .font(Font.custom("Monaco", size: 54.0))
                    .padding(.top)
                    .onTapGesture {
                        showClock.toggle()
                    }
                    .onReceive(timer) { _ in
                        time = dateFormatter.string(from: .now)
                    }
            }
            
            VStack (spacing: 0) {
                
                GeometryReader { proxy in
                    
                    VStack {
                        MapView(manager: sessionViewModel)
                            .frame(width: proxy.size.width, height: proxy.size.width, alignment: .bottom)
                            .opacity(opacity)
                            .mask(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom))
                            .mask(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .leading, endPoint: .trailing))
                            .mask(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .bottomLeading, endPoint: .topTrailing))
                            .mask(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing))
                    }.frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
                    
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation (.linear(duration: 1.0)) {
                            self.opacity = 1
                        }
                    }
                }
                HStack {
                    if sessionViewModel.status == .stop {
                        ZStack {
                            Circle()
                                .frame(width: 50.0, height: 50.0)
                                .foregroundColor(.red)
                            
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                        }.onTapGesture {
                            showSessionSetUp.toggle()
                        }
                        .sheet(isPresented: $showSessionSetUp) {
                            SessionSettingsView(typeSession: $sessionViewModel.session.typeSession, timer: $timerBeforeSession)
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .fill(Color.red)
                        HStack {
                            if sessionViewModel.status == .stop {
                                Text("Start")
                                    .font(.headline)
                                    .padding(.leading, 50)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            else {
                                Text(sessionViewModel.status == .running ? "Pause" : "Resume")
                                    .font(.headline)
                                    .padding(.leading, 50)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            Spacer()
                            switch sessionViewModel.session.typeSession {
                            case .cycling:
                                Image(systemName: "bicycle")
                                    .frame(width: 50.0, height: 50.0).padding(.horizontal)
                                    .foregroundColor(.white)
                            case .walking:
                                Image(systemName: "figure.walk")
                                    .frame(width: 50.0, height: 50.0).padding(.horizontal)
                                    .foregroundColor(.white)
                            case .running:
                                FontIcon.text(.awesome5Solid(code: .running), fontsize: 20)
                                    .frame(width: 50.0, height: 50.0).padding(.horizontal)
                                    .foregroundColor(.white)
                                
                            default:
                                EmptyView()
                            }
                            
                        }
                    }
                    .frame(maxWidth: 210, maxHeight: 50)
                    .onTapGesture {
                        guard sessionViewModel.canStart else {
                            showAlertLocationNeeded.toggle()
                            return
                        }
                        
                        if sessionViewModel.status == .stop {
                            showOverlayBeforeSession = true
                        }
                        else {
                            pause()
                        }
                        
                    }
                    .fullScreenCover(isPresented: $showOverlayBeforeSession, onDismiss: {
                        self.start()
                    }) {
                        StartUpSessionView(show: $showOverlayBeforeSession, timeBeforeSession: $timerBeforeSession)
                    }
                    
                    
                    if sessionViewModel.status != .stop {
                        ZStack {
                            Circle()
                                .frame(width: 50.0, height: 50.0)
                            Image(systemName: "stop.fill")
                                .foregroundColor(.white)
                        }
                        .scaleEffect(scaleStopButton)
                        .offset(x: scaleStopButton == 1 ? 0 : 10, y: 0)
                        .foregroundColor(.red)
                        .gesture(
                            LongPressGesture(minimumDuration: 1)
                                .onEnded { _ in
                                    withAnimation {
                                        scaleStopButton = 1
                                    }
                                    self.finish()
                                }
                                .onChanged { _ in
                                    withAnimation {
                                        scaleStopButton = 1.2
                                    }
                                }
                        )
                    }
                }.padding()
            }
        }
        .alert(isPresented: $showAlertLocationNeeded) {
            Alert(title: Text("Location is needed"), message: Text("Please, make sure that in iPhone settings location for Bike Trekr is allowed"))
        }
        .onReceive(timer) { _ in
            guard autoPause else { return }
            if sessionViewModel.status == .running {
                if sessionViewModel.speed < 1 {
                    checkSpeed += 1
                } else {
                    checkSpeed = 0
                }
            } else {
                checkSpeed = 0
            }
            
            if checkSpeed == 5 {
                self.pause()
            }
            
            if sessionViewModel.speed > 1 && sessionViewModel.status == .pause {
                self.pause()
            }
            
        }
    }
    
    func pause() {
        sessionViewModel.pause()
        generatorLight.impactOccurred()
    }
    
    func start() {
        sessionViewModel.start()
        generatorLight.impactOccurred()
        checkSpeed = 0
    }
    
    func finish() {
        
        generatorHeavy.impactOccurred()
        checkSpeed = 0
        
        guard let userId = auth.user?.uid else {
            showLogin.toggle()
            return
        }
        
        sessionViewModel.session.userId = userId
        
        if sessionViewModel.session.distance > 0 {
            sessionRepo.add(sessionViewModel.session)
        }
        
        sessionViewModel.finish()
        
    }
}
