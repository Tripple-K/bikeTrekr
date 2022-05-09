import SwiftUI
import SwiftUIFontIcon


struct SessionView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var session: Session
    let dayFormatter = DateFormatter(with: "dd.MM.y")
    let timeFormatter = DateFormatter(with: "hh:mm aa")
    
    @State var overviewMapView: DetailMapController?
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (alignment: .top) {
                overviewMapView
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .frame(maxWidth: 100, minHeight: 100)
                HStack (alignment: .top, spacing: 0) {
                    VStack (alignment: .leading) {
                        Text("\(dayFormatter.string(from: session.date))").font(.headline)
                        Text("At \(timeFormatter.string(from: session.date))").foregroundColor(.gray).font(.body)
                        switch session.typeSession {
                        case .cycling:
                            Image(systemName: "bicycle")
                                .padding(.top)
                        case .walking:
                            Image(systemName: "figure.walk")
                                .padding(.top)
                        case .running:
                            FontIcon.text(.awesome5Solid(code: .running), fontsize: 20)
                                .padding(.top)
                        default:
                            EmptyView()
                        }
                    }
                    Spacer()
                    HStack (spacing: 0) {
                        Text("More")
                            .font(.headline)
                        Image(systemName: "chevron.right")
                            .frame(width: 20, height: 20)
                    }
                    .offset(x: -4)
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                overviewMapView = DetailMapController(locations: session.locations)
                overviewMapView?.userInteraction = false
                overviewMapView?.iconMap = true
            }
            .padding(.leading)
            .padding(.top)
            HStack (spacing: 20) {
                VStack (alignment: .leading) {
                    HStack {
                        Text("\(String(format: "%.2f", session.distance).replacingOccurrences(of: ".", with: ","))").font(.headline)
                        Text("km").foregroundColor(.gray).font(.body)
                    }
                    Text("distance").foregroundColor(.gray).font(.body)
                }.frame(maxWidth: .infinity)
                VStack (alignment: .leading) {
                    HStack {
                        Text("\(String(format: "%.1f", session.avSpeed).replacingOccurrences(of: ".", with: ","))").font(.headline)
                        Text("km/h").foregroundColor(.gray).font(.body)
                    }
                    Text("av. speed").foregroundColor(.gray).font(.body)
                }.frame(maxWidth: .infinity)
                VStack (alignment: .trailing) {
                    Text("\(session.duration)").font(.headline)
                    Text("time").foregroundColor(.gray).font(.body)
                }.frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}


extension DateFormatter {
    convenience init(with dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
