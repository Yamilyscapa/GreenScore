import SwiftUI

struct ContentView: View {

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            NavigationStack {
                VStack {
                    Navbar()
                }
            }
        }
    }
}

#Preview {
    ContentView().modelContainer(for: Footprint.self, inMemory: true)
}
