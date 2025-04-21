import SwiftUI

struct ProfileView: View {
    @ObservedObject var waterViewModel: WaterViewModel
    @State private var userProfile = UserProfile()
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    if isEditing {
                        HStack {
                            Text("Age")
                            Spacer()
                            TextField("Age", value: $userProfile.age, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Weight (kg)")
                            Spacer()
                            TextField("Weight", value: $userProfile.weight, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Text("Height (cm)")
                            Spacer()
                            TextField("Height", value: $userProfile.height, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Picker("Gender", selection: $userProfile.gender) {
                            ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue)
                            }
                        }
                        
                        Picker("Activity Level", selection: $userProfile.activityLevel) {
                            ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue)
                            }
                        }
                    } else {
                        ProfileInfoRow(title: "Age", value: "\(userProfile.age) years")
                        ProfileInfoRow(title: "Weight", value: "\(Int(userProfile.weight)) kg")
                        ProfileInfoRow(title: "Height", value: "\(Int(userProfile.height)) cm")
                        ProfileInfoRow(title: "Gender", value: userProfile.gender.rawValue)
                        ProfileInfoRow(title: "Activity Level", value: userProfile.activityLevel.rawValue)
                    }
                }
                
                Section(header: Text("Recommended Water Intake")) {
                    let recommended = userProfile.recommendedDailyIntake()
                    HStack {
                        Text("Based on your profile:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(recommended)) ml")
                            .bold()
                    }
                    
                    Button("Use This Recommendation") {
                        waterViewModel.updateDailyGoal(target: recommended)
                    }
                    .disabled(isEditing)
                }
                
                if isEditing {
                    Section {
                        Button("Save Changes") {
                            // Save profile changes
                            saveProfile()
                            isEditing = false
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("My Profile")
            .toolbar {
                Button(isEditing ? "Cancel" : "Edit") {
                    if isEditing {
                        // Revert changes by reloading profile
                        loadProfile()
                    }
                    isEditing.toggle()
                }
            }
            .onAppear {
                loadProfile()
            }
        }
    }
    
    private func saveProfile() {
        // Save profile to UserDefaults
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    private func loadProfile() {
        // Load profile from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: userData) {
            userProfile = decoded
        }
    }
}

struct ProfileInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
