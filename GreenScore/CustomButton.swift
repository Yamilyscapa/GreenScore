import SwiftUI

struct CustomButton: View {
    
    var buttonText: String
    var isSmall = false
    
    var body: some View {
        VStack {
            Button(action: {
            
            }) {
                Text(buttonText)
            }
            .font(.system(size: 18,weight: .bold))
            .foregroundColor(.white)
            .frame(width: isSmall ? 100 : 350, height: 50)
            .background(Color("MainColor"))
            .cornerRadius(100)
            .hoverEffect(.lift)
        }
    }
}
