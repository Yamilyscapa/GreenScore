import Foundation

struct ActionAnalyzer {

    static let categories = [
        "water",
        "energy",
        "transport",
        "waste"
    ]

    static func classifyAction(_ text: String, apiKey: String, completion: @escaping (String) -> Void) {
        guard !text.isEmpty else {
            completion("⚠️ Empty input")
            return
        }

        let url = URL(string: "https://api-inference.huggingface.co/models/facebook/bart-large-mnli")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "inputs": text,
            "parameters": ["candidate_labels": categories]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API Error: \(error.localizedDescription)")
                completion("Classification error: Network issue")
                return
            }
            
            guard let data = data else {
                completion("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let labels = json["labels"] as? [String],
                   let scores = json["scores"] as? [Double],
                   !labels.isEmpty,
                   !scores.isEmpty {
                    
                    guard let topScore = scores.first, topScore >= 0.5 else {
                        completion("⚠️ Action not clearly recognized (low confidence)")
                        return
                    }

                    let topLabel = labels.first ?? "Unknown"
                    var result = "Category: \(topLabel.capitalized)"
                    var emissions: Double? = nil

                    if let emissionInfo = estimateEmissions(from: text, category: topLabel) {
                        result += "\nAdding: \(emissionInfo.text)"
                        emissions = emissionInfo.value
                        
                        // Save emissions to UserDefaults
                        saveEmissions(for: topLabel, value: emissions ?? 0)
                        
                        // Calculate percentage for display
                        let emissionPercentage = calculatePercentage(for: topLabel, value: emissions ?? 0)
                        result += "\nImpact: \(Int(emissionPercentage))%"
                    }

                    saveToHistory(text, result: result)
                    completion(result)
                } else {
                    completion("Response format error")
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion("Classification error: Data parsing issue")
            }
        }.resume()
    }

    static func estimateEmissions(from text: String, category: String) -> (text: String, value: Double)? {
        let lowercased = text.lowercased()

        switch category {
        case "transport":
            var emission: Double = 0.0
            // Look for distance patterns like "5km" or "10 miles"
            let pattern = #"(\d+(\.\d+)?)\s*(km|kilometers|kilometres|miles|mi)"#
            let regex = try? NSRegularExpression(pattern: pattern)
            
            if let match = regex?.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)),
               let range = Range(match.range(at: 1), in: lowercased),
               let distanceValue = Double(lowercased[range]),
               let unitRange = Range(match.range(at: 3), in: lowercased) {
                
                let unit = String(lowercased[unitRange])
                var distance = distanceValue
                
                // Convert miles to kilometers if needed
                if unit.contains("mi") {
                    distance *= 1.60934 // Miles to kilometers conversion
                }
                
                if lowercased.contains("car") || lowercased.contains("drove") {
                    // Average car emissions: ~120g CO2 per km
                    emission = distance * 0.12
                } else if lowercased.contains("bus") {
                    // Bus emissions per passenger: ~30g CO2 per km
                    emission = distance * 0.03
                } else if lowercased.contains("plane") || lowercased.contains("flight") {
                    // Plane emissions per passenger: ~150g CO2 per km
                    emission = distance * 0.15
                } else if lowercased.contains("train") || lowercased.contains("subway") {
                    // Train emissions per passenger: ~20g CO2 per km
                    emission = distance * 0.02
                } else if lowercased.contains("bike") || lowercased.contains("walk") || lowercased.contains("ran") {
                    // Zero emissions for walking/biking
                    emission = 0.0
                } else {
                    // Default to car if transportation mode not specified
                    emission = distance * 0.12
                }
            } else {
                // If no specific distance found, estimate based on typical trip
                if lowercased.contains("car") || lowercased.contains("drove") {
                    emission = 1.2 // Assuming ~10km car trip
                } else if lowercased.contains("bus") {
                    emission = 0.3 // Assuming ~10km bus trip
                } else if lowercased.contains("plane") || lowercased.contains("flight") {
                    emission = 15.0 // Assuming short flight
                } else if lowercased.contains("bike") || lowercased.contains("walk") || lowercased.contains("ran") {
                    emission = 0.0
                }
            }

            return (String(format: "%.2f kg CO₂", emission), emission)

        case "water":
            var emission: Double = 0.0

            if lowercased.contains("shower") {
                emission += 35.0 // Average shower ~35 liters
                if lowercased.contains("long") || lowercased.contains("hot") {
                    emission += 15.0 // Long showers use more
                }
            }
            if lowercased.contains("bath") || lowercased.contains("bathtub") {
                emission += 80.0 // Bath ~80 liters
            }
            if lowercased.contains("brushed") && (lowercased.contains("teeth") || lowercased.contains("tooth")) {
                if lowercased.contains("tap on") || lowercased.contains("running water") {
                    emission += 8.0 // Leaving tap running ~8 liters
                } else {
                    emission += 1.0 // Conserving water ~1 liter
                }
            }
            if lowercased.contains("toilet") || lowercased.contains("flush") {
                emission += 6.0 // Toilet flush ~6 liters
            }
            if lowercased.contains("dishes") || lowercased.contains("dishwasher") {
                if lowercased.contains("dishwasher") {
                    emission += 15.0 // Dishwasher ~15 liters
                } else {
                    emission += 30.0 // Hand washing with running water ~30 liters
                }
            }
            if lowercased.contains("laundry") || lowercased.contains("washing machine") {
                emission += 50.0 // Washing machine ~50 liters
            }
            
            // If no specific activity found but water category detected
            if emission == 0 {
                emission = 5.0 // Default water usage estimate
            }

            return (String(format: "%.1f liters", emission), emission)

        case "energy":
            var emission: Double = 0.0

            if lowercased.contains("air conditioning") || lowercased.contains("ac") {
                if lowercased.contains("hour") || lowercased.contains("hr") {
                    let pattern = #"(\d+(\.\d+)?)\s*(hour|hr|hours|hrs)"#
                    let regex = try? NSRegularExpression(pattern: pattern)
                    if let match = regex?.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)),
                       let range = Range(match.range(at: 1), in: lowercased),
                       let hours = Double(lowercased[range]) {
                        emission += hours * 1.5 // ~1.5 kWh per hour
                    } else {
                        emission += 1.5 // Default 1 hour
                    }
                } else {
                    emission += 1.5 // Default 1 hour
                }
            }
            if lowercased.contains("heater") || lowercased.contains("heating") {
                emission += 2.0 // ~2 kWh
            }
            if lowercased.contains("laundry") || lowercased.contains("washing machine") {
                emission += 1.0 // ~1 kWh per load
            }
            if lowercased.contains("dryer") {
                emission += 3.0 // ~3 kWh per load
            }
            if lowercased.contains("charging") || lowercased.contains("charged") {
                if lowercased.contains("phone") {
                    emission += 0.01 // ~0.01 kWh for phone
                } else if lowercased.contains("laptop") {
                    emission += 0.06 // ~0.06 kWh for laptop
                } else {
                    emission += 0.03 // Default electronic device
                }
            }
            if lowercased.contains("light") || lowercased.contains("lamp") {
                emission += 0.05 // ~0.05 kWh per light
                
                // Check if multiple lights mentioned
                let pattern = #"(\d+)\s*(light|lamp|bulb)"#
                let regex = try? NSRegularExpression(pattern: pattern)
                if let match = regex?.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased)),
                   let range = Range(match.range(at: 1), in: lowercased),
                   let count = Int(lowercased[range]) {
                    emission += 0.05 * Double(count - 1) // Add for additional lights
                }
            }
            if lowercased.contains("tv") || lowercased.contains("television") {
                emission += 0.1 // ~0.1 kWh per hour
            }
            if lowercased.contains("computer") || lowercased.contains("laptop") || lowercased.contains("desktop") {
                emission += 0.15 // ~0.15 kWh per hour
            }
            
            // If no specific activity found but energy category detected
            if emission == 0 {
                emission = 0.5 // Default energy usage estimate
            }

            return (String(format: "%.2f kWh", emission), emission)

        case "waste":
            var emission: Double = 0.0

            if lowercased.contains("recycled") || lowercased.contains("recycling") {
                emission -= 0.1 // Recycling reduces waste impact
            }
            if lowercased.contains("compost") {
                emission -= 0.2 // Composting reduces waste impact
            }
            if lowercased.contains("reusable") || lowercased.contains("reused") {
                emission -= 0.15 // Reusing items reduces waste
            }
            if lowercased.contains("plastic") && !lowercased.contains("avoided") && !lowercased.contains("no plastic") {
                emission += 0.03 // Plastic waste
            }
            if lowercased.contains("bottle") && !lowercased.contains("reusable") {
                emission += 0.02 // Single-use bottle
            }
            if lowercased.contains("disposable") || lowercased.contains("single use") || lowercased.contains("single-use") {
                emission += 0.05 // Disposable items
            }
            if lowercased.contains("food waste") || lowercased.contains("threw away food") {
                emission += 0.5 // Food waste has high impact
            }
            if lowercased.contains("paper") && !lowercased.contains("recycled") {
                emission += 0.01 // Paper waste
            }
            
            // If just generic waste mentioned with no specifics
            if emission == 0 && (lowercased.contains("trash") || lowercased.contains("garbage")) {
                emission = 0.2 // Default waste estimate
            }

            return (String(format: "%.2f kg waste", emission), emission)

        default:
            return ("0.00 units", 0.0)
        }
    }

    static func saveToHistory(_ input: String, result: String) {
        let entry = "\(formattedDate()): \(input) → \(result)"
        var history = UserDefaults.standard.stringArray(forKey: "actionHistory") ?? []
        history.insert(entry, at: 0)
        
        // Limit history size to prevent excessive storage
        if history.count > 100 {
            history = Array(history.prefix(100))
        }
        
        UserDefaults.standard.set(history, forKey: "actionHistory")
    }
    
    static func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    static func getHistory() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "actionHistory") ?? []
    }

    static func saveEmissions(for category: String, value: Double) {
        let key = "emissions_\(category.lowercased())"
        let current = UserDefaults.standard.double(forKey: key)
        UserDefaults.standard.set(current + value, forKey: key)
    }

    static func getEmissions(for category: String) -> Double {
        return UserDefaults.standard.double(forKey: "emissions_\(category.lowercased())")
    }

    static func getAllEmissions() -> [String: Double] {
        var result: [String: Double] = [:]
        for category in categories {
            result[category] = getEmissions(for: category)
        }
        return result
    }
    
    static func calculatePercentage(for category: String, value: Double) -> Double {
        // Calculate a percentage based on relative impact within category
        switch category {
        case "water":
            // Water: percentage based on daily recommended usage (~150L)
            return min(100, (value / 150.0) * 100)
        case "energy":
            // Energy: percentage based on average daily usage (~10kWh)
            return min(100, (value / 10.0) * 100)
        case "transport":
            // Transport: percentage based on average daily carbon budget (~7kg CO2)
            return min(100, (value / 7.0) * 100)
        case "waste":
            // Waste: percentage based on average daily waste (~1.5kg)
            return min(100, (value / 1.5) * 100)
        default:
            return 0
        }
    }
    
    static func resetAllData() {
        for category in categories {
            UserDefaults.standard.removeObject(forKey: "emissions_\(category)")
        }
        UserDefaults.standard.removeObject(forKey: "actionHistory")
    }
}
