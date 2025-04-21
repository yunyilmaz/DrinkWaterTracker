import Foundation
import UserNotifications

struct ReminderSchedule: Codable, Identifiable {
    var id = UUID()
    var hour: Int
    var minute: Int
    var isEnabled: Bool
    var days: [Int] // 1-7 representing days of week
    
    var formattedTime: String {
        let dateComponents = DateComponents(hour: hour, minute: minute)
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class NotificationManager: ObservableObject {
    @Published var reminderSchedules: [ReminderSchedule] = []
    private let userDefaults = UserDefaults.standard
    private let remindersKey = "waterReminders"
    
    init() {
        loadReminders()
    }
    
    func scheduleNotifications() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                self.configureNotifications()
            }
        }
    }
    
    private func configureNotifications() {
        // Remove existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule new notifications based on reminder schedules
        for reminder in reminderSchedules where reminder.isEnabled {
            for dayOfWeek in reminder.days {
                let content = UNMutableNotificationContent()
                content.title = "Water Reminder"
                content.body = "It's time to drink some water!"
                content.sound = UNNotificationSound.default
                
                var components = DateComponents()
                components.hour = reminder.hour
                components.minute = reminder.minute
                components.weekday = dayOfWeek
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(reminder.id)-\(dayOfWeek)",
                    content: content,
                    trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    func addReminder(hour: Int, minute: Int) {
        let newReminder = ReminderSchedule(hour: hour, minute: minute, isEnabled: true, days: [1,2,3,4,5,6,7])
        reminderSchedules.append(newReminder)
        saveReminders()
        scheduleNotifications()
    }
    
    func removeReminders(at indices: IndexSet) {
        reminderSchedules.remove(atOffsets: indices)
        saveReminders()
        scheduleNotifications()
    }
    
    func toggleReminder(_ reminder: ReminderSchedule) {
        if let index = reminderSchedules.firstIndex(where: { $0.id == reminder.id }) {
            reminderSchedules[index].isEnabled.toggle()
            saveReminders()
            scheduleNotifications()
        }
    }
    
    func saveReminders() {
        do {
            let data = try JSONEncoder().encode(reminderSchedules)
            userDefaults.set(data, forKey: remindersKey)
        } catch {
            print("Failed to save reminders: \(error.localizedDescription)")
        }
    }
    
    private func loadReminders() {
        guard let data = userDefaults.data(forKey: remindersKey) else { return }
        
        do {
            reminderSchedules = try JSONDecoder().decode([ReminderSchedule].self, from: data)
        } catch {
            print("Failed to load reminders: \(error.localizedDescription)")
        }
    }
}