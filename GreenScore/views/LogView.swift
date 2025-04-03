import Foundation
import SwiftUI

struct LogView: View {
    @State private var userAction = ""
    @State private var detectedCategory: String?
    @State private var showAlert = false
    @State private var isLoading = false

    let categories: [(label: String, icon: String, color: Color)] = [
        ("Water", "drop.fill", .blue),
        ("Energy", "bolt.fill", .yellow),
        ("Transport", "car.fill", .red),
        ("Waste", "trash.fill", .green),
    ]

    let predefinedHabits: [String: [String]] = [
        "Water": ["Drank water", "Took a shower", "Washed dishes"],
        "Energy": ["Turned off lights", "Used AC less", "Charged phone"],
        "Transport": ["Carpooled", "Biked", "Walked"],
        "Waste": ["Recycled", "Composted", "Avoided plastic"]
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Log actions")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }.padding(.top, 16).padding(.leading, 30)

            Spacer()
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 20), count: 2),
                spacing: 20
            ) {
                ForEach(categories, id: \.label) { category in
                    CustomButton2(
                        label: category.label,
                        icon: category.icon,
                        color: category.color,
                        habits: predefinedHabits[category.label] ?? [],
                        userAction: $userAction
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
            Spacer()
    
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Register daily actions").foregroundColor(.gray)
                    TextEditor(
                        text: $userAction
                    )
                    .background(Color(.gray))
                    .frame(height: 45)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray, lineWidth: 4).opacity(0.25)
                    )
                    .cornerRadius(12)
                }
                Button {
                    classifyHabit(phrase: userAction)
                    print(ActionAnalyzer.getAllEmissions())
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: .white)
                            )
                            .frame(width: 50, height: 50)
                            .background(Color("MainColor"))
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(Color("MainColor"))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Category Detected"),
                message: Text(detectedCategory ?? "Unknown"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    func getAPIKey(named keyName: String) -> String {
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path),
            let key = dict[keyName] as? String
        {
            return key
        }
        return ""
    }
    func classifyHabit(phrase: String) {
        isLoading = true
        let token = getAPIKey(named: "HF_API_TOKEN")

        ActionAnalyzer.classifyAction(phrase, apiKey: token) { result in
            DispatchQueue.main.async {
                isLoading = false
                detectedCategory = result
                showAlert = true
                userAction = ""
            }
        }
    }
}

#Preview {
    LogView()
}
