import Foundation
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater)!
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            completion(success)
        }
    }
    
    func saveWaterIntake(amount: Double, date: Date, completion: @escaping (Bool, Error?) -> Void) {
        let unit = HKUnit.literUnit(with: .milli)
        let quantity = HKQuantity(unit: unit, doubleValue: amount)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: date, end: date)
        
        healthStore.save(sample) { success, error in
            completion(success, error)
        }
    }
    
    // Add methods to fetch data from HealthKit
}