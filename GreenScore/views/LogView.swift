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

    var body: some View {
        VStack {
            Spacer()
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: 20), count: 2),
                spacing: 20
            ) {
                ForEach(categories, id: \.label) { category in
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 90, height: 90)
                            Image(systemName: category.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                        Text(category.label)
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            // Campo de texto + botón al lado derecho
            HStack {
                TextField(
                    "Describe your sustainable action...", text: $userAction
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                Button {
                    classifyHabit(phrase: userAction)
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
        guard !phrase.isEmpty else { return }
        isLoading = true
        let url = URL(
            string:
                "https://api-inference.huggingface.co/models/facebook/bart-large-mnli"
        )!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = getAPIKey(named: "HF_API_TOKEN")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let labels = [
            "water saving",
            "energy saving",
            "transport",
            "waste reduction",
        ]

        let body: [String: Any] = [
            "inputs": phrase,
            "parameters": ["candidate_labels": labels],
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
            }

            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data)
                    as? [String: Any],
                let labels = json["labels"] as? [String]
            else {
                DispatchQueue.main.async {
                    detectedCategory = "Classification failed"
                    showAlert = true
                }
                return
            }
            DispatchQueue.main.async {
                detectedCategory = labels.first ?? "Unknown"
                showAlert = true
                userAction = ""  // opcional: limpia el campo después
            }
        }.resume()
    }
}
#Preview {
    LogView()
}
