import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            Navbar()
        }
    }
}

#Preview {
    ContentView().modelContainer(for: Footprint.self, inMemory: true)
}
