

import SwiftUI
import SwiftUIFontIcon
import MapKit

struct DetailSessionView: View {
    @State var session: Session
    
    let dateFormatter = DateFormatter(with: "dd.MM.yyyy hh:mm a")
    
    @State var fullscreenMap = false
    
    @State var overviewMapView: DetailMapController?
    
    
    var body: some View {
        
        VStack (spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack (spacing: 0) {
                    Text("OVERALL")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, -16)
                        .padding(.leading)
                    VStack (spacing: 0) {
                        HStack {
                            Text("Distance")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%.2f", session.distance).replacingOccurrences(of: ".", with: ","))").bold()
                                Text("km").foregroundColor(.gray).italic().font(.body)
                            }
                        }
                        .padding()
                        HStack {
                            Text("Duration")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(session.duration)")
                            }
                        }.padding()
                        HStack {
                            Text("Average Speed")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%.1f", session.avSpeed).replacingOccurrences(of: ".", with: ","))").bold()
                                Text("km/h").foregroundColor(.gray).italic().font(.body)
                            }
                            
                        }.padding()
                        HStack {
                            Text("Max Speed")
                            Spacer()
                            HStack (spacing: 4) {
                                Text("\(String(format: "%.1f", session.maxSpeed).replacingOccurrences(of: ".", with: ","))").bold()
                                Text("km/h").foregroundColor(.gray).italic().font(.body)
                            }
                            
                        }.padding()
                        HStack {
                            Text("Session Type")
                            Spacer()
                            switch session.typeSession {
                            case .bike:
                                Image(systemName: "bicycle")
                                    .frame(width: 24, height: 24)
                            case .walk:
                                Image(systemName: "figure.walk")
                                    .frame(width: 24, height: 24)
                            case .run:
                                FontIcon.text(.awesome5Solid(code: .running), fontsize: 20).frame(width: 24, height: 24)
                            default:
                                EmptyView()
                            }
                        }.padding()
                    }
                    .font(.headline)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("darkGray")))
                    .padding()
                    Text("MAP")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.bottom, -16)
                        .padding(.leading)
                    overviewMapView
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                        .onTapGesture {
                            self.fullscreenMap.toggle()
                        }
                   
                    .padding()
                }
                
            }
            .onAppear {
                overviewMapView = DetailMapController(locations: session.locations)
                overviewMapView?.userInteraction = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("background"))
        .fullScreenCover(isPresented: $fullscreenMap) {
            DetailMapController(locations: session.locations)
                .ignoresSafeArea()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .overlay {
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
                    }
                }
        }
    }
}

