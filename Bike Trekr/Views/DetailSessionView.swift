

import SwiftUI
import SwiftUIFontIcon
import MapKit

struct DetailSessionView: View {
    @State var session: Session
    
    let dateFormatter = DateFormatter(with: "dd.MM.yyyy hh:mm a")
    
    @State var fullscreenMap = false
    
    @State var overviewMapView: DetailMapView?
    
    
    var body: some View {
        
        VStack (spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack {
                    
                    VStack (spacing: 0) {
                        HStack {
                            Text("Distance")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%.2f", session.distance).replacingOccurrences(of: ".", with: ","))").bold()
                                Text("km").foregroundColor(.gray).font(.body)
                            }
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
                        HStack {
                            Text("Duration")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%02d",  self.session.duration / 3600)):\(String(format: "%02d", ( self.session.duration % 3600) / 60)):\(String(format: "%02d", ( self.session.duration % 3600) % 60))")
                            }
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
                        HStack {
                            Text("Average Speed")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%.1f", session.avSpeed).replacingOccurrences(of: ".", with: ","))").bold()
                                Text("km/h").foregroundColor(.gray).font(.body)
                            }
                            
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
                        HStack {
                            Text("Max Speed")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%.1f", session.maxSpeed).replacingOccurrences(of: ".", with: ","))").bold()
                                Text("km/h").foregroundColor(.gray).font(.body)
                            }
                            
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 0, trailing: 16))
                        HStack {
                            Text("Session Type")
                            Spacer()
                            switch session.typeSession {
                            case .cycling:
                                Image(systemName: "bicycle")
                                    .frame(width: 24, height: 24)
                            case .walking:
                                Image(systemName: "figure.walk")
                                    .frame(width: 24, height: 24)
                            case .running:
                                FontIcon.text(.awesome5Solid(code: .running), fontsize: 20).frame(width: 24, height: 24)
                            }
                        }
                        .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .font(.headline)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                    .padding()
                    
                    
                    overviewMapView
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                        .onTapGesture {
                            self.fullscreenMap.toggle()
                        }
                   
                    .padding()
                    
                   
                    VStack () {
                        HStack {
                            Text("").frame(width: 45)
                            Text("Distance").frame(width: 80, alignment: .leading)
                            Text("Speed").frame(alignment: .leading)
                            Spacer()
                            Text("Time")
                        }
                        .padding(10)
                        ForEach(0..<session.intervals.count, id: \.self) { index in
                            let interval = session.intervals[index]
                            HStack {
                                Text("\(interval.index)").frame(width: 45)
                                Text("\(String(format: "%.1f", interval.distance)) km").frame(width: 80, alignment: .leading)
                                
                                Text("\(String(format: "%.2f", interval.avSpeed)) km/h").frame(alignment: .leading)
                                Spacer()
                                Text("\(String(format: "%02d", interval.duration / 3600)):\(String(format: "%02d", (interval.duration % 3600) / 60)):\(String(format: "%02d", (interval.duration % 3600) % 60))")
                            }
                            .padding(10)
                        }

                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                    .padding()
                   
                }
                
            }
            .onAppear {
                overviewMapView = DetailMapView(session: session)
                overviewMapView?.userInteraction = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("background"))
        .fullScreenCover(isPresented: $fullscreenMap) {
            DetailMapView(session: session)
                .ignoresSafeArea()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .overlay (
                    VStack (alignment: .leading) {
                        Button(action: {
                            self.fullscreenMap = false
                        }, label: {
                            HStack (spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .foregroundColor(.red)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                Text("Back").foregroundColor(.red).font(.headline)
                            }
                            .frame(width: 100, height: 40)
                        })
                    }, alignment: .topLeading)
        }
    }
}

