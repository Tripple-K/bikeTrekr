
import SwiftUI
import HealthKit

struct SessionSettingsView: View {
    @Binding var typeSession: SessionType
    @Binding var timer: Int
    @State var showPicker: Bool = false
    @State var showGoalPicker: Bool = false
    
    @AppStorage("autoPause") var autoPause = true
    @AppStorage("goal") var goal: GoalType = .none
    @AppStorage("duration") var seconds: Int = 1800 {
        didSet {
            duration = "\(String(format: "%02d", seconds / 3600)):\(String(format: "%02d", (seconds % 3600) / 60)):\(String(format: "%02d", (seconds % 3600) % 60))"
        }
    }
    
    @AppStorage("distance") var distance = 5.0 {
        didSet {
            guard distance >= 0 else {
                distance = oldValue
                return
            }
        }
    }
    
    @GestureState var tap = false
    let generatorHeavy = UIImpactFeedbackGenerator(style: .heavy)
    let generatorLight = UIImpactFeedbackGenerator(style: .soft)
    
    var distanceFormatted: String {
        return "\(String(format: "%02d", Int(distance))),\(String(format: "%02d", Int(distance.truncatingRemainder(dividingBy: 1) * 100)))"
    }
    
    @State var duration = "00:30:00"
    
    
    var body: some View {
        VStack {
            List {
                Section {
                    Text("Session Type")
                    Picker("Session Type", selection: $typeSession) {
                        ForEach(SessionType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Auto Pause", isOn: $autoPause).tint(.red)
                    HStack {
                        Text("Set A Goal")
                        Spacer()
                        Picker("Set a Goal", selection: $goal) {
                            ForEach(GoalType.allCases, id: \.self) { goal in
                                Text("\(goal == .none ? "None" : goal.rawValue.capitalized)")
                                    .background(Color.white)
                            }
                        }
                        .accentColor(.red)
                        .pickerStyle(.menu)
                    }
                    
                    switch goal {
                    case .distance:
                        HStack {
                            Text("Distance")
                            Spacer()
                            Text("\(distanceFormatted) km")
                                .foregroundColor(.red)
                        }
                        .onTapGesture {
                            withAnimation {
                                showGoalPicker.toggle()
                            }
                        }
                    case .duration:
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(duration)")
                                .foregroundColor(.red)
                        }.onTapGesture {
                            withAnimation {
                                showGoalPicker.toggle()
                            }
                        }
                    case .speed:
                        HStack {
                            Text("Mark laps")
                        }
                    case .none:
                        EmptyView()
                    }
                    
                    Text("Delay start timer \(timer) secs")
                        .onTapGesture {
                            withAnimation {
                            showPicker.toggle()
                        }
                    }
                    CollapsableWheelPicker("Delay start timer \(timer)", showsPicker: $showPicker, selection: $timer) {
                        ForEach(0...10, id: \.self) { i in
                           Text("\(i) secs")
                        }
                    }.offset(y: showPicker ? 0 : -100)
                }
                .listRowSeparator(.hidden)
            }
            if showGoalPicker {
                VStack {
                    switch goal {
                    case .distance:
                        Text("Distance").foregroundColor(.gray)
                        HStack {
                            Button (action: {
                                distance -= 0.05
                                generatorLight.impactOccurred()
                            }, label: {
                                Image(systemName: "minus.square")
                                    .font(.title)
                            })
                            .foregroundColor(.red)
                            Text("\(distanceFormatted) km")
                                .font(.title2)
                                .simultaneousGesture(LongPressGesture(minimumDuration: 0)
                                    .updating($tap) { curr, gest, transition in
                                        generatorHeavy.impactOccurred()
                                        gest = curr
                                    }
                                    .sequenced(before: DragGesture().onChanged { gesture in
                                        generatorLight.impactOccurred()
                                        distance = abs(gesture.translation.height / 5)
                                    })
                                )
                            Button (action: {
                                distance += 0.05
                                generatorLight.impactOccurred()
                            }, label: {
                                Image(systemName: "plus.app")
                                    .font(.title)
                            })
                            .foregroundColor(.red)
                        }
                    case .duration:
                        Text("Duration").foregroundColor(.gray)
                        HStack {
                            Button (action: {
                                seconds -= 5
                                generatorLight.impactOccurred()
                            }, label: {
                                Image(systemName: "minus.square")
                                    .font(.title)
                            })
                            .foregroundColor(.red)
                            Text(duration)
                                .font(.title2)
                                .simultaneousGesture(LongPressGesture(minimumDuration: 0)
                                    .updating($tap) { curr, gest, transition in
                                        generatorLight.impactOccurred()
                                        gest = curr
                                    }
                                    .sequenced(before: DragGesture().onChanged { gesture in
                                        generatorLight.impactOccurred()
                                        seconds = Int(abs(gesture.translation.height * 10))
                                    })
                                )
                            Button (action: {
                                seconds += 5
                                generatorLight.impactOccurred()
                            }, label: {
                                Image(systemName: "plus.app")
                                    .font(.title)
                            })
                            .foregroundColor(.red)
                        }
                    default:
                        EmptyView()
                    }
                   
                }.offset(y: showGoalPicker ? 0 : 300)
            }
        }
        
    }
}




