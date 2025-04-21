import Foundation

struct WaterIntake: Identifiable, Codable {
    var id = UUID()
    var amount: Double // in ml
    var timestamp: Date
    
    init(amount: Double, timestamp: Date = Date()) {
        self.amount = amount
        self.timestamp = timestamp
    }
}

struct DailyWaterGoal: Codable {
    var target: Double // daily target in ml
    
    init(target: Double = 2000) {
        self.target = target
    }
}
