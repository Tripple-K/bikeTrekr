

import SwiftUI
import Combine


struct SectionPicker: View {
    @Binding var selection: Int
    @Binding var sections: [String]
    
    @State var next = false
    @State var prev = false
    var body: some View {
       
        if sections.count > 0 {
            HStack {
                Button(action: {
                    if selection > 0 {
                        selection -= 1
                    }
                    if selection <= 0 {
                        prev = true
                    } else {
                        prev = false
                    }
                    if selection >= sections.count - 1 {
                        next = true
                    } else {
                        next = false
                    }
                }, label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 40, height: 40)
                })
                .disabled(prev)
                Spacer()
                Text("\(sections[selection])")
                Spacer()
                Button(action: {
                    if selection < sections.count - 1 {
                        selection += 1
                    }
                    if selection <= 0 {
                        prev = true
                    } else {
                        prev = false
                    }
                    if selection >= sections.count - 1 {
                        next = true
                    } else {
                        next = false
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                        .frame(width: 40, height: 40)
                })
                .disabled(next)
            }
            .onAppear {
                if selection <= 0 {
                    prev = true
                } else {
                    prev = false
                }
                if selection >= sections.count - 1 {
                    next = true
                } else {
                    next = false
                }
            }
            .onChange(of: sections) { _ in
                
                if selection <= 0 {
                    prev = true
                } else {
                    prev = false
                }
                if selection >= sections.count - 1 {
                    next = true
                } else {
                    next = false
                }
            }
        }
        
        
    }
}


