import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: DrinkWaterTracker.AuthViewModel
    @ObservedObject var waterViewModel: WaterViewModel
    @State private var showingAddIntake = false
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with user info and logout
            HStack {
                Text("Welcome, \(authViewModel.username)")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            // Progress display
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(waterViewModel.getDailyProgress()))
                    .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: waterViewModel.getDailyProgress())
                
                VStack {
                    Text("\(Int(waterViewModel.todayTotal)) ml")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("of \(Int(waterViewModel.dailyGoal.target)) ml")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 240)
            .padding()
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Water intake progress: \(Int(waterViewModel.getDailyProgress() * 100))%")
            .accessibilityValue("\(Int(waterViewModel.todayTotal)) ml of \(Int(waterViewModel.dailyGoal.target)) ml")
            
            // List of today's water intakes
            List {
                if waterViewModel.waterIntakes.isEmpty {
                    Text("No water intake recorded for today")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(waterViewModel.waterIntakes.filter {
                        Calendar.current.isDateInToday($0.timestamp)
                    }) { intake in
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("\(Int(intake.amount)) ml")
                            Spacer()
                            Text(intake.timestamp, style: .time)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: waterViewModel.removeWaterIntake)
                }
            }
            
            // Add water intake button
            Button(action: {
                showingAddIntake.toggle()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Water Intake")
                        .bold()
                }
            }
            .primaryButton(color: .blue)
            .padding(.bottom)
        }
        .sheet(isPresented: $showingAddIntake) {
            AddWaterIntakeView(waterViewModel: waterViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(waterViewModel: waterViewModel, authViewModel: authViewModel)
        }
        .onAppear {
            waterViewModel.calculateTodayTotal()
        }
    }
}

#Preview {
    HomeView(
        authViewModel: AuthViewModel(),
        waterViewModel: WaterViewModel()
    )
}
