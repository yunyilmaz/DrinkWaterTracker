import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var waterViewModel: WaterViewModel
    @ObservedObject var authViewModel: AuthViewModel
    
    @State private var dailyGoal: String
    @State private var selectedPreset: Int? // Track selected preset for visual feedback
    
    init(waterViewModel: WaterViewModel, authViewModel: AuthViewModel) {
        self.waterViewModel = waterViewModel
        self.authViewModel = authViewModel
        _dailyGoal = State(initialValue: "\(Int(waterViewModel.dailyGoal.target))")
        // Initialize selectedPreset if current value matches a preset
        let currentGoal = Int(waterViewModel.dailyGoal.target)
        _selectedPreset = State(initialValue: [1500, 2000, 2500, 3000].contains(currentGoal) ? currentGoal : nil)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Water Target")) {
                    TextField("Daily goal (ml)", text: $dailyGoal)
                        .keyboardType(.numberPad)
                    
                    Button("Save Changes") {
                        saveGoal()
                    }
                    .disabled(dailyGoal.isEmpty || Double(dailyGoal) == nil || Double(dailyGoal)! <= 0)
                }
                
                Section(header: Text("Preset Targets")) {
                    // Replaced the HStack with a grid layout for better separation
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach([1500, 2000, 2500, 3000], id: \.self) { preset in
                            Button(action: {
                                // Update text field
                                dailyGoal = "\(preset)"
                                // Update selected preset for visual feedback
                                selectedPreset = preset
                                // Immediately save the change
                                waterViewModel.updateDailyGoal(target: Double(preset))
                                // Give visual feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }) {
                                Text("\(preset) ml")
                                    .padding(10)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedPreset == preset ? Color.blue : Color.blue.opacity(0.1))
                                    .foregroundColor(selectedPreset == preset ? .white : .blue)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle()) // This ensures tap area is properly constrained
                        }
                    }
                }
                
                Section(header: Text("Account")) {
                    Button("Sign Out") {
                        authViewModel.logout()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Ensure any pending changes are saved before dismissing
                        saveGoal()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // Helper method to save goal
    private func saveGoal() {
        if let goal = Double(dailyGoal), goal > 0 {
            waterViewModel.updateDailyGoal(target: goal)
            // Update selected preset if the entered value matches a preset
            selectedPreset = [1500, 2000, 2500, 3000].contains(Int(goal)) ? Int(goal) : nil
        }
    }
}

// MARK: - Preview Provider
#Preview {
    SettingsView(
        waterViewModel: WaterViewModel(),
        authViewModel: AuthViewModel()
    )
}
