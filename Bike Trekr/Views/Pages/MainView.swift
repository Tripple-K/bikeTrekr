import SwiftUI
import MapKit
import SwiftUIFontIcon
import Combine

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
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
    @State var showAlertLocationNeeded = false

    @State var showGoalSheet = false
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State var mapView = MapView()
    
    @State var interval = 1
    
    @AppStorage("autoPause") var autoPause = true
    
    @AppStorage("goal") var goal: GoalType = .none
    
    @AppStorage("timerBeforeSession") var timerBeforeSession: Int = 3
    
    var body: some View {
        VStack (spacing: 0) {
            SessionCurrentInfoView().environmentObject(sessionViewModel)
            if goal == .speed && sessionViewModel.status != .stop {
                Text("Interval \(interval)")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            VStack (spacing: 0) {
                
                GeometryReader { proxy in
                    
                    ZStack {
                       
                        mapView
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
                    } else if sessionViewModel.status != .stop && goal == .speed {
                        ZStack {
                            Circle()
                                .frame(width: 50.0, height: 50.0)
                                .foregroundColor(.red)
                            
                            Image(systemName: "flag.fill")
                                .foregroundColor(.white)
                        }.onTapGesture {
                            
                        }
//                        .sheet(isPresented: $showSessionSetUp) {
//                            SessionSettingsView(typeSession: $sessionViewModel.session.typeSession, timer: $timerBeforeSession)
//                        }
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
                        StartUpSessionView(timeBeforeSession: $timerBeforeSession)
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
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                sessionViewModel.saveTemp()
            default:
                break
            }
        }
        .onDisappear {
            sessionViewModel.saveTemp()
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
            return
        }
        
        sessionViewModel.session.userId = userId
        
        if sessionViewModel.session.distance > 0 {
            SessionRepository.shared.add(sessionViewModel.session)
        }
        
        sessionViewModel.finish()
    }
    
    func validate(text: String, with regex: String) -> Bool {
            guard let gRegex = try? NSRegularExpression(pattern: regex) else {
                return false
            }
        
            let range = NSRange(location: 0, length: text.utf16.count)
            
            if gRegex.firstMatch(in: text, options: [], range: range) != nil {
                return true
            }
            
            return false
    }
}


enum GoalType: String, CaseIterable, Codable {
    case duration, distance, speed, none = "Set a goal"
}
