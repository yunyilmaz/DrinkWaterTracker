import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: DrinkWaterTracker.AuthViewModel
    @ObservedObject var waterViewModel: WaterViewModel
    @State private var showingAddIntake = false
    @State private var showingSettings = false
    @State private var showingEditIntake = false
    @State private var selectedIntake: WaterIntake?
    
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
            
            // Replace circle progress with human figure animation
            HumanWaterFillView(
                progress: waterViewModel.getDailyProgress(),
                totalAmount: Int(waterViewModel.todayTotal),
                targetAmount: Int(waterViewModel.dailyGoal.target)
            )
            .padding(.horizontal)
            
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
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(action: {
                                selectedIntake = intake
                                showingEditIntake = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: {
                                if let index = waterViewModel.waterIntakes.firstIndex(where: { $0.id == intake.id }) {
                                    waterViewModel.removeWaterIntake(at: IndexSet([index]))
                                }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .onTapGesture {
                            selectedIntake = intake
                            showingEditIntake = true
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
        .sheet(isPresented: $showingEditIntake) {
            if let intake = selectedIntake {
                EditWaterIntakeView(waterViewModel: waterViewModel, intake: intake)
            }
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
