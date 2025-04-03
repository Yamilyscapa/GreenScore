import Foundation
import SwiftData
import SwiftUI

struct LogView: View {
    @Environment(\.modelContext) private var context
    @Query var footprintModels: [Footprint]
    @Query var streakModels: [Streak]
    @State private var userAction = ""
    @State private var detectedCategory: String?
    @State private var showAlert = false
    @State private var isLoading = false
    @State private var isInitialized = false

    let categories: [(label: String, icon: String, color: Color)] = [
        ("Water", "drop.fill", .blue),
        ("Energy", "bolt.fill", .yellow),
        ("Transport", "car.fill", .red),
        ("Waste", "trash.fill", .green),
    ]

    let predefinedHabits: [String: [String]] = [
        "Water": ["Took a shower", "Brushed teeth", "Washed dishes"],
        "Energy": ["Turned off lights", "Used AC less", "Charged phone"],
        "Transport": ["Drove 5km by car", "Took bus for 10km", "Walked instead of driving"],
        "Waste": ["Recycled plastic", "Used reusable bottle", "Composted food waste"]
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
                }.onAppear {
                    // Initialize Footprint model only once if needed
                    initializeFootprintIfNeeded()
                }
                Button(action: {
                    guard !isLoading && !userAction.isEmpty else { return }
                    isLoading = true
                    classifyHabit(phrase: userAction)
                }) {
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

    func initializeFootprintIfNeeded() {
        // Check if we already have a Footprint object
        if footprintModels.isEmpty {
            // Only create a new one if none exists
            context.insert(
                Footprint(
                    energy: 0.0, transport: 0.0, waste: 0.0,
                    water: 0.0)
            )
        }
        
        // Similarly for Streak if needed
        if streakModels.isEmpty {
            context.insert(Streak(days: 0))
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
        let token = getAPIKey(named: "HF_API_TOKEN")

        ActionAnalyzer.classifyAction(phrase, apiKey: token) { result in
            DispatchQueue.main.async {
                self.detectedCategory = result
                self.showAlert = true
                
                // Get emissions data after classification
                let emissionsData = ActionAnalyzer.getAllEmissions()
                
                // Update Footprint with actual emissions data
                self.updateFootprintModel(with: emissionsData)
                
                self.userAction = ""
                self.isLoading = false
            }
        }
    }
    
    func updateFootprintModel(with emissionsData: [String: Double]) {
        guard let footprint = footprintModels.first else {
            print("No FootprintModel found")
            return
        }
        
        // Update each category with normalized values
        // The scaling factors ensure consistent representation across categories
        for (category, value) in emissionsData {
            switch category {
            case "water":
                // Water in liters - scale appropriately for visualization
                footprint.water = value / 10.0 // Normalize to keep progress bars in reasonable range
            case "energy":
                // Energy in kWh - scale appropriately for visualization
                footprint.energy = value / 10.0
            case "transport":
                // Transport in kg CO2 - normalize with appropriate factor
                footprint.transport = value / 10.0
            case "waste":
                // Waste in kg - scale appropriately for visualization
                footprint.waste = value / 10.0
            default:
                break
            }
        }
        
        // Calculate total environmental impact
        // Use weighted sum of all categories for a balanced total score
        footprint.total = CGFloat(
            (footprint.water * 1.0) +
            (footprint.energy * 1.2) +
            (footprint.transport * 1.5) +
            (footprint.waste * 1.3)
        )
        
        // Update streak (assuming one action per day)
        if let streak = streakModels.first {
            streak.days += 1
        }
    }}

#Preview {
    LogView()
}
