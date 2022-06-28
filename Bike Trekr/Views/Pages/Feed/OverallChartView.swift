import SwiftUI


struct OverallChartView: View {
    
    let keys: [String]
    let values: [Double]
    
    @State var keyHover: String = ""
    
    @State var maxHeight: CGFloat = 0
    
    var maxValue: Double {
        return values.max() ?? 0
    }
    
    var body: some View {
        if keys.count == values.count {
            GeometryReader { proxy in
                HStack (alignment: .bottom) {
                    ForEach(0..<keys.count, id: \.self) { index in
                        VStack {
                            Text(String(format: "%.1f", values[index]))
                                .font(.subheadline)
                                .scaleEffect(keys[index] == keyHover ? 1.5 : 0.6, anchor: .top)
                                .foregroundColor(.gray)
                                .opacity(keys[index] == keyHover ? 1 : 0)
                            
                            ZStack (alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(.gray)
                                    .opacity(0.3)
                                    .frame(height: proxy.size.width / 2)
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(.red)
                                    .frame(height: maxHeight * (values[index]) / maxValue)
                            }
                            .onTapGesture {
                                withAnimation (.default.speed(1)) {
                                    keyHover = keys[index]
                                }
                            }
                            Text("\(keys[index])")
                                .font(.headline)
                        }
                        
                    }
                    
                }
                .frame(width: proxy.size.width, height: proxy.size.width * 0.7, alignment: .bottom)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring()) {
                            self.maxHeight = proxy.size.width / 2
                        }
                    }
                }
            }
        } else {
            Text("NO CORRECT DATA")
        }
       
    }
}

struct OverallChartView_Previews: PreviewProvider {
    static var previews: some View {
        OverallChartView(keys: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], values: [10, 50, 30, 40, 70, 10, 5]).padding()
    }
}

