 import SwiftUI


struct SessionsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20).fill(colorScheme == .dark ? .white : .black).frame(maxHeight: 250)
            VStack {
                HStack {
                    Text("2021/01/07").foregroundColor(colorScheme == .dark ? .black : .white)
                }
                HStack {
                    Text("")
                }
            }
            
            
        }
    }
}



struct DetailSessionView_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        SessionsView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 8")
    }
}
