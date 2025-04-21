import Foundation

struct UserProfile: Codable {
    var weight: Double = 70 // kg
    var height: Double = 170 // cm
    var activityLevel: ActivityLevel = .moderate
    var gender: Gender = .notSpecified
    var age: Int = 30
    
    enum ActivityLevel: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case light = "Light Activity"
        case moderate = "Moderate Activity"
        case active = "Very Active"
        case extreme = "Extremely Active"
    }
    
    enum Gender: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case notSpecified = "Not Specified"
    }
    
    func recommendedDailyIntake() -> Double {
        // Basic formula - can be refined
        var baseAmount = weight * 30 // ml per kg
        
        // Adjust for activity level
        switch activityLevel {
        case .sedentary: baseAmount *= 0.8
        case .light: baseAmount *= 0.9
        case .moderate: break // No adjustment
        case .active: baseAmount *= 1.1
        case .extreme: baseAmount *= 1.2
        }
        
        // Round to nearest 100ml
        return round(baseAmount / 100) * 100
    }
}