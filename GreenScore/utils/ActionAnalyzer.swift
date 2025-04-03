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

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let labels = json["labels"] as? [String],
                  let scores = json["scores"] as? [Double] else {
                completion("Classification failed")
                return
            }

            guard let topScore = scores.first, topScore >= 0.6 else {
                completion("⚠️ Action not recognized")
                return
            }

            let topLabel = labels.first ?? "Unknown"
            var result = "Category: \(topLabel)"
            var emissions: Double? = nil

            if let emissionInfo = estimateEmissions(from: text, category: topLabel) {
                result += "\nAdding: \(emissionInfo.text)"
                emissions = emissionInfo.value
            }

            saveToHistory(text, result: result)
            if let emissions = emissions {
                saveEmissions(for: topLabel, value: emissions)
            }
            completion(result)
        }.resume()
    }

    static func estimateEmissions(from text: String, category: String) -> (text: String, value: Double)? {
        let lowercased = text.lowercased()

        switch category {
        case "transport":
            let pattern = #"(\d+(\.\d+)?)\s?(km|kilometers|kilometres)"#
            let regex = try? NSRegularExpression(pattern: pattern)
            let match = regex?.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased))

<<<<<<< HEAD
        guard let match = match,
              let range = Range(match.range(at: 1), in: lowercased),
              let distance = Double(lowercased[range]) else {
            return nil
        }

        // Estimates the CO2 emissions dependign of the transportation method
        if lowercased.contains("car") {
            let emission = distance * 0.2
            return (String(format: "Estimated emissions: %.2f kg CO₂", emission), emission)
        } else if lowercased.contains("bus") {
            let emission = distance * 0.1
            return (String(format: "Estimated emissions: %.2f kg CO₂", emission), emission)
        } else if lowercased.contains("plane") || lowercased.contains("flight") {
            let emission = distance * 0.25
            return (String(format: "Estimated emissions: %.2f kg CO₂", emission), emission)
        } else if lowercased.contains("bike") || lowercased.contains("walk") {
            return ("Estimated emissions: 0.00 kg CO₂", 0.0)
        } else {
=======
            guard let match = match,
                  let range = Range(match.range(at: 1), in: lowercased),
                  let distance = Double(lowercased[range]) else {
                return nil
            }

            if lowercased.contains("car") {
                let emission = distance * 0.2
                return (String(format: "%.2f kg CO₂", emission), emission)
            } else if lowercased.contains("bus") {
                let emission = distance * 0.1
                return (String(format: "%.2f kg CO₂", emission), emission)
            } else if lowercased.contains("plane") || lowercased.contains("flight") {
                let emission = distance * 0.25
                return (String(format: "%.2f kg CO₂", emission), emission)
            } else if lowercased.contains("bike") || lowercased.contains("walk") {
                return ("0.00 kg CO₂", 0.0)
            }

        case "water":
            var emission: Double = 0.0

            if lowercased.contains("shower") || lowercased.contains("bathed") || lowercased.contains("took a bath") {
                emission += 1.5
            }
            if lowercased.contains("brushed my teeth") || lowercased.contains("brushed teeth") || lowercased.contains("toothbrush") {
                emission += 0.3
            }
            if lowercased.contains("toilet") || lowercased.contains("used the bathroom") || lowercased.contains("bathroom") {
                emission += 0.5
            }
            if lowercased.contains("washed dishes") || lowercased.contains("dishwasher") {
                emission += 1.0
            }

            return emission > 0 ? (String(format: "%.2f L water", emission), emission) : nil

        case "energy":
            var emission: Double = 0.0

            if lowercased.contains("air conditioning") || lowercased.contains("ac") {
                emission += 1.2
            }
            if lowercased.contains("laundry") || lowercased.contains("washing") || lowercased.contains("washed clothes") {
                emission += 1.0
            }
            if lowercased.contains("charging") || lowercased.contains("charged") || lowercased.contains("charged my phone") {
                emission += 0.2
            }
            if lowercased.contains("heater") || lowercased.contains("heating") {
                emission += 0.8
            }

            return emission > 0 ? (String(format: "%.2f kWh", emission), emission) : nil

        case "waste":
            var emission: Double = 0.0

            if lowercased.contains("snack") || lowercased.contains("chips") || lowercased.contains("wrapper") {
                emission += 0.1
            }
            if lowercased.contains("bottle") {
                emission += 0.2
            }
            if lowercased.contains("disposable") || lowercased.contains("plastic cup") || lowercased.contains("fork") {
                emission += 0.3
            }
            if lowercased.contains("appliance") || lowercased.contains("furniture") || lowercased.contains("electronic") {
                emission += 1.5
            }

            return emission > 0 ? (String(format: "%.2f kg waste", emission), emission) : nil

        default:
>>>>>>> 536db42882ab30d72993300b2a182e86ad5f4677
            return nil
        }
        return nil
    }

    static func saveToHistory(_ input: String, result: String) {
        let entry = "\(Date()): \(input) → \(result)"
        var history = UserDefaults.standard.stringArray(forKey: "actionHistory") ?? []
        history.insert(entry, at: 0)
        UserDefaults.standard.set(history, forKey: "actionHistory")
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
}
