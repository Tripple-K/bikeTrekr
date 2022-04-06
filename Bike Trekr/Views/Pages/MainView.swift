import SwiftUI
import MapKit
import SwiftUIFontIcon

struct MainView: View {
    
    @Binding var showLogin: Bool
    
    @State var manager = LocationManager()
    @EnvironmentObject var sessionRepo: SessionRepository
    @EnvironmentObject var auth: AuthenticationService
    
    let generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let generatorLight = UIImpactFeedbackGenerator(style: .light)
    
    let gradientColors: [Color] = [.clear, .clear.opacity(0.5), .black.opacity(0.7), .black, .black, .black.opacity(0.7), .clear.opacity(0.5), .clear]
    @State var opacity: Double = 0
    
    @State var checkSpeed = 0
    
    @State var showSessionSetUp: Bool = false
    @State var status: StatusTracker = .stop
    
    @State var scaleStopButton = 1.0
    
    @State var typeSession: TypeSession = .bike
    @AppStorage("timerBeforeSession") var timerBeforeSession: Int = 3
    
    @State var showOverlayBeforeSession = false
    @State var dateStart = Date()
    
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeNow = ""
    var dateFormatter: DateFormatter {
        let fmtr = DateFormatter()
        fmtr.dateFormat = "hh:mm a"
        return fmtr
    }
    
    @State var showAlertLocationNeeded = false
    
    @State var showClock = false
    
    @AppStorage("autoPause") var autoPause = true
    
    @ObservedObject var stopWatchManager = StopWatchManager()
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                
                VStack {
                    HStack {
                        Text("\(manager.speed * 3.6 > 0 ? (String(format: "%.1f", manager.speed * 3.6)) : "0.0")").font(Font.custom("Monaco", size: 36.0))
                        Text("km/h").font(Font.custom("Monaco", size: 18)).padding(.top, 13)
                    }
                    Text("speed").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                }
                
                VStack {
                    HStack {
                        Text("\(String(format: "%.2f", manager.distance))").font(Font.custom("Monaco", size: 36.0).italic())
                        Text("km").font(Font.custom("Monaco", size: 18.0).italic()).padding(.top, 13)
                        Spacer()
                        Text("\(manager.avgSpeed * 3.6 > 0 ? (String(format: "%.1f", manager.avgSpeed * 3.6)) : "0.0")").font(Font.custom("Monaco", size: 36.0).italic())
                        Text("km/h").font(Font.custom("Monaco", size: 18).italic()).padding(.top, 13)
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("distance").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                        Spacer()
                        Text("av. speed").font(Font.custom("Monaco", size: 18)).foregroundColor(Color.gray)
                    }.padding(.horizontal)
                }
                Text("\(stopWatchManager.secondsElapsed)")
                    .font(Font.custom("Monaco", size: 54.0))
                    .padding(.top)
            }
            
            VStack (spacing: 0) {
                
                GeometryReader { proxy in
                    
                    VStack {
                        MapView(manager: manager)
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
                    if status == .stop {
                        ZStack {
                            Circle()
                                .frame(width: 50.0, height: 50.0)
                            
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white)
                        }.onTapGesture {
                            showSessionSetUp.toggle()
                        }
                        .sheet(isPresented: $showSessionSetUp) {
                            SessionSettingsView(typeSession: $typeSession, timer: $timerBeforeSession)
                        }
                        .foregroundColor(.red)
                    }
                    ZStack {
                        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                            .fill(Color.red)
                        HStack {
                            if status == .stop {
                                Text("Start")
                                    .font(.headline)
                                    .padding(.leading, 50)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            else {
                                Text(status == .running ? "Pause" : "Resume")
                                    .font(.headline)
                                    .padding(.leading, 50)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            Spacer()
                            if typeSession == .bike {
                                Image(systemName: "bicycle")
                                    .frame(width: 50.0, height: 50.0).padding(.horizontal)
                                .foregroundColor(.white) }
                            else if typeSession == .run {
                                FontIcon.text(.awesome5Solid(code: .running), fontsize: 20)
                                    .frame(width: 50.0, height: 50.0).padding(.horizontal)
                                    .foregroundColor(.white)
                            }
                            else if typeSession == .walk {
                                Image(systemName: "figure.walk")
                                    .frame(width: 50.0, height: 50.0).padding(.horizontal)
                                    .foregroundColor(.white)
                            }
                            
                        }
                    }
                    .frame(maxWidth: 210, maxHeight: 50)
                    .onTapGesture {
                        guard manager.canWeStart else {
                            showAlertLocationNeeded.toggle()
                            return
                        }
                        
                        if !manager.tracking {
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
                    
                    
                    if status != .stop {
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
            Alert(title: Text("Location is needed"), message: Text("Please, make sure that in iPhone settings location for Bike Trekr is allow"))
        }
        .onReceive(timer) { _ in
            guard autoPause else { return }
            if status == .running {
                if manager.speed < 1 {
                    checkSpeed += 1
                } else {
                    checkSpeed = 0
                }
            } else {
                checkSpeed = 0
            }
            
            if checkSpeed == 15 {
                self.pause()
            }
        }
    }
    
    func pause() {
        manager.locations2d.removeAll()
        status = status == .running ? .pause : .running
        manager.tracking = true
        manager.paused = status == .pause ? true : false
        generatorLight.impactOccurred()
        if stopWatchManager.paused {
            stopWatchManager.startWatch()
        }
        else if stopWatchManager.running {
            stopWatchManager.pauseWatch()
        }
        else {
            stopWatchManager.startWatch()
        }
    }
    
    func start() {
        dateStart = Date()
        manager.speeds.removeAll()
        manager.locations2d.removeAll()
        status = status == .running ? .pause : .running
        manager.tracking = true
        manager.paused = status == .pause ? true : false
        generatorLight.impactOccurred()
        checkSpeed = 0
        if stopWatchManager.paused {
            stopWatchManager.startWatch()
        }
        else if stopWatchManager.running {
            stopWatchManager.pauseWatch()
        }
        else {
            stopWatchManager.startWatch()
        }
    }
    
    func finish() {
        guard let user = auth.user else {
            showLogin.toggle()
            return
        }
        
        let locations = manager.locations.compactMap { location in
            return Location(location: location)
        }
        
        if manager.distance > 0 {
            let session = Session(distance: manager.distance, duration: stopWatchManager.secondsElapsed, date: dateStart, avSpeed: manager.avgSpeed, maxSpeed: manager.speeds.max() ?? 0, typeSession: typeSession.rawValue, userId: user.uid, locations: locations)
            sessionRepo.add(session)
        }
        
        generatorHeavy.impactOccurred()
        status = .stop
        manager.speed = 0
        manager.tracking = false
        manager.finished = true
        manager.paused = false
        manager.locations2d.removeAll()
        manager.distance = 0
        manager.speeds.removeAll()
        stopWatchManager.reset()
        checkSpeed = 0
    }
    
    
}

enum StatusTracker {
    case pause, stop, running
}



struct MainView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        MainView(showLogin: $show)
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 12")
    }
}

