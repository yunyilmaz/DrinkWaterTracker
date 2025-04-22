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
    
    func updateWaterIntake(id: UUID, amount: Double) {
        if let index = waterIntakes.firstIndex(where: { $0.id == id }) {
            waterIntakes[index].amount = amount
            saveData()
            calculateTodayTotal()
        }
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
    
    func averageIntake(for timeframe: StatisticsView.Timeframe) -> Double {
        let filteredIntakes = getFilteredIntakes(for: timeframe)
        
        // Group intakes by day
        let calendar = Calendar.current
        var dailyTotals: [Date: Double] = [:]
        
        for intake in filteredIntakes {
            let dayStart = calendar.startOfDay(for: intake.timestamp)
            dailyTotals[dayStart, default: 0] += intake.amount
        }
        
        // Calculate average
        let sum = dailyTotals.values.reduce(0, +)
        let count = max(dailyTotals.count, 1) // Avoid division by zero
        
        return sum / Double(count)
    }
    
    func achievementRate(for timeframe: StatisticsView.Timeframe) -> Double {
        let filteredIntakes = getFilteredIntakes(for: timeframe)
        let calendar = Calendar.current
        var daysAchieved = 0
        var dailyTotals: [Date: Double] = [:]
        
        // Calculate daily totals
        for intake in filteredIntakes {
            let dayStart = calendar.startOfDay(for: intake.timestamp)
            dailyTotals[dayStart, default: 0] += intake.amount
        }
        
        // Count days that met the target
        for (_, total) in dailyTotals {
            if total >= dailyGoal.target {
                daysAchieved += 1
            }
        }
        
        // Calculate achievement rate
        let daysCount = max(dailyTotals.count, 1) // Avoid division by zero
        return Double(daysAchieved) / Double(daysCount)
    }
    
    func bestDay(for timeframe: StatisticsView.Timeframe) -> String {
        let filteredIntakes = getFilteredIntakes(for: timeframe)
        let calendar = Calendar.current
        var dailyTotals: [Date: Double] = [:]
        
        // Calculate daily totals
        for intake in filteredIntakes {
            let dayStart = calendar.startOfDay(for: intake.timestamp)
            dailyTotals[dayStart, default: 0] += intake.amount
        }
        
        // Find the day with maximum intake
        if let bestDay = dailyTotals.max(by: { $0.value < $1.value }) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "\(formatter.string(from: bestDay.key)) (\(Int(bestDay.value)) ml)"
        }
        
        return "No data available"
    }
    
    private func getFilteredIntakes(for timeframe: StatisticsView.Timeframe) -> [WaterIntake] {
        let calendar = Calendar.current
        let today = Date()
        let startDate: Date
        
        switch timeframe {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: today) ?? today
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: today) ?? today
        }
        
        return waterIntakes.filter { $0.timestamp >= startDate && $0.timestamp <= today }
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
