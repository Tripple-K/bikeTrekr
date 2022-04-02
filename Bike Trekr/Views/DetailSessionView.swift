 import SwiftUI


struct DetailSessionView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var session: Session
    let dayFormatter = DateFormatter(with: "dd.MM.y")
    let timeFormatter = DateFormatter(with: "hh:mm aa")
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (alignment: .top, spacing: 0) {
                VStack (alignment: .leading) {
                    Text("\(dayFormatter.string(from: session.date))").font(.headline)
                    Text("At \(timeFormatter.string(from: session.date))").foregroundColor(.gray).font(.body)
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
               
            }.padding(.leading)
            HStack (spacing: 20) {
                VStack (alignment: .leading) {
                    HStack {
                        Text("\(String(format: "%.2f", session.distance))").font(.headline)
                        Text("km/h").foregroundColor(.gray).font(.body)
                    }
                    Text("distance").foregroundColor(.gray).font(.body)
                }
                VStack (alignment: .leading) {
                    HStack {
                        Text("\(String(format: "%.2f", session.avSpeed))").font(.headline)
                        Text("km/h").foregroundColor(.gray).font(.body)
                    }
                    Text("av. speed").foregroundColor(.gray).font(.body)
                }
                VStack (alignment: .trailing) {
                    Text("\(session.duration)").font(.headline)
                    Text("time").foregroundColor(.gray).font(.body)
                }
            }.padding()
        }
    }
}






extension DateFormatter {
    convenience init(with dateFormat: String) {
        self.init()
        self.dateFormat = dateFormat
    }
}
