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

            if let emissionInfo = estimateEmissions(from: text) {
                result += "\n\(emissionInfo.text)"
                emissions = emissionInfo.value
            }

            saveToHistory(text, result: result)
            if let emissions = emissions {
                saveEmissions(for: topLabel, value: emissions)
            }
            completion(result)
        }.resume()
    }

    static func estimateEmissions(from text: String) -> (text: String, value: Double)? {
        let lowercased = text.lowercased()

        let pattern = #"(\d+(\.\d+)?)\s?(km|kilometers|kilometres)"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let match = regex?.firstMatch(in: lowercased, range: NSRange(lowercased.startIndex..., in: lowercased))

        guard let match = match,
              let range = Range(match.range(at: 1), in: lowercased),
              let distance = Double(lowercased[range]) else {
            return nil
        }

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
            return nil
        }
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
