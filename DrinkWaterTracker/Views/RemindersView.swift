import SwiftUI

struct RemindersView: View {
    @ObservedObject var notificationManager: NotificationManager
    @State private var showingAddReminder = false
    @State private var newReminderHour = 8
    @State private var newReminderMinute = 0
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Daily Reminders")) {
                    if notificationManager.reminderSchedules.isEmpty {
                        Text("No reminders scheduled")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(notificationManager.reminderSchedules) { reminder in
                            HStack {
                                Text(reminder.formattedTime)
                                
                                Spacer()
                                
                                if reminder.isEnabled {
                                    Text("Active")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                } else {
                                    Text("Disabled")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            // Delete reminder logic
                            deleteReminders(at: indexSet)
                        }
                    }
                }
                
                Section {
                    Button("Add New Reminder") {
                        showingAddReminder = true
                    }
                }
            }
            .navigationTitle("Water Reminders")
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView(
                    hour: $newReminderHour,
                    minute: $newReminderMinute,
                    onSave: {
                        notificationManager.addReminder(hour: newReminderHour, minute: newReminderMinute)
                        showingAddReminder = false
                    },
                    onCancel: {
                        showingAddReminder = false
                    }
                )
            }
        }
    }
    
    private func deleteReminders(at offsets: IndexSet) {
        // Implementation for deleting reminders
        // notificationManager.removeReminders(at: offsets)
    }
}

struct AddReminderView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Reminder Time")) {
                    DatePicker(
                        "Time",
                        selection: Binding(
                            get: {
                                var components = DateComponents()
                                components.hour = hour
                                components.minute = minute
                                return Calendar.current.date(from: components) ?? Date()
                            },
                            set: { date in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: date)
                                hour = components.hour ?? hour
                                minute = components.minute ?? minute
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarItems(
                leading: Button("Cancel", action: onCancel),
                trailing: Button("Save", action: onSave)
            )
        }
    }
}
