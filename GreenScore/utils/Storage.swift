import SwiftData

@Model
class Footprint {
    var energy: Double
    var transport: Double
    var waste: Double
    var water: Double
    var total: Double
    

    init(energy: Double, transport: Double, waste: Double, water: Double, total: Double) {
        self.energy = energy
        self.transport = transport
        self.waste = waste
        self.water = water
        self.total = total
    }
}

@Model
class Points {
    var totalPoints: UInt8 = 0
    
    init(totalPoints: UInt8) {
        self.totalPoints = totalPoints
    }
}

@Model
class Streak {
    var days: UInt8 = 0
    
    init(days: UInt8) {
        self.days = days
    }
}
