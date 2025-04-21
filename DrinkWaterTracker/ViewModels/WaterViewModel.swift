import Foundation
import SwiftUI
import Combine

enum WaterModelError: Error, LocalizedError {
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save water intake data"
        case .loadFailed:
            return "Failed to load water intake data"
        }
    }
}

class WaterViewModel: ObservableObject {
    @Published var waterIntakes: [WaterIntake] = []
    @Published var dailyGoal: DailyWaterGoal = DailyWaterGoal()
    @Published var todayTotal: Double = 0
    @Published var errorMessage: String = ""
    
    private let userDefaults = UserDefaults.standard
    private let waterIntakesKey = "waterIntakes"
    private let dailyGoalKey = "dailyGoal"
    
    init() {
        loadData()
        calculateTodayTotal()
    }
    
    func addWaterIntake(amount: Double) {
        let newIntake = WaterIntake(amount: amount)
        waterIntakes.append(newIntake)
        saveData()
        calculateTodayTotal()
        
        // Send notification for accessibility
        NotificationCenter.default.post(
            name: NSNotification.Name("WaterIntakeAdded"),
            object: nil,
            userInfo: ["amount": amount]
        )
    }
    
    func removeWaterIntake(at offsets: IndexSet) {
        waterIntakes.remove(atOffsets: offsets)
        saveData()
        calculateTodayTotal()
    }
    
    func updateDailyGoal(target: Double) {
        dailyGoal = DailyWaterGoal(target: target)
        saveData()
    }
    
    func calculateTodayTotal() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        todayTotal = waterIntakes
            .filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    func getDailyProgress() -> Double {
        return min(todayTotal / max(dailyGoal.target, 1.0), 1.0)
    }
    
    private func saveData() {
        do {
            let encodedIntakes = try JSONEncoder().encode(waterIntakes)
            userDefaults.set(encodedIntakes, forKey: waterIntakesKey)
            
            let encodedGoal = try JSONEncoder().encode(dailyGoal)
            userDefaults.set(encodedGoal, forKey: dailyGoalKey)
        } catch {
            errorMessage = WaterModelError.saveFailed.localizedDescription
            print("Error saving data: \(error)")
        }
    }
    
    private func loadData() {
        do {
            if let intakesData = userDefaults.data(forKey: waterIntakesKey) {
                waterIntakes = try JSONDecoder().decode([WaterIntake].self, from: intakesData)
            }
            
            if let goalData = userDefaults.data(forKey: dailyGoalKey) {
                dailyGoal = try JSONDecoder().decode(DailyWaterGoal.self, from: goalData)
            }
        } catch {
            errorMessage = WaterModelError.loadFailed.localizedDescription
            print("Error loading data: \(error)")
        }
    }
    
    // MARK: - Testing Helper Methods
    func resetData() {
        waterIntakes = []
        dailyGoal = DailyWaterGoal()
        saveData()
        calculateTodayTotal()
    }
}
