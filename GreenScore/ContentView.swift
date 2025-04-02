import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            CustomButton(buttonText: "Continue")
            Spacer()
            Navbar()
        }.edgesIgnoringSafeArea(.bottom)
    }}

#Preview {
    ContentView()
}
