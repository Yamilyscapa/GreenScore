import SwiftData
import Foundation

@Model
class Footprint {
    @Attribute(.unique) var id = UUID()
    @Attribute var energy: Double
    @Attribute var transport: Double
    @Attribute var waste: Double
    @Attribute var water: Double
    @Attribute var total: CGFloat = 0.0
    
    
    init(energy: Double, transport: Double, waste: Double, water: Double) {
        self.energy = energy
        self.transport = transport
        self.waste = waste
        self.water = water
    }
}

@Model
class Points {
    @Attribute var totalPoints: UInt8 = 0
    
    init(totalPoints: UInt8) {
        self.totalPoints = totalPoints
    }
}

@Model
class Streak {
    @Attribute var days: UInt8 = 0
    
    init(days: UInt8) {
        self.days = days
    }
}
