import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @StateObject private var authViewModel = DrinkWaterTracker.AuthViewModel()
    @StateObject private var waterViewModel = DrinkWaterTracker.WaterViewModel()
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                TabView {
                    NavigationView {
                        HomeView(authViewModel: authViewModel, waterViewModel: waterViewModel)
                            .navigationBarHidden(true)
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    StatisticsView(waterViewModel: waterViewModel)
                        .tabItem {
                            Label("Statistics", systemImage: "chart.bar.fill")
                        }
                    
                    ProfileView(waterViewModel: waterViewModel)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                    
                    RemindersView(notificationManager: notificationManager)
                        .tabItem {
                            Label("Reminders", systemImage: "bell.fill")
                        }
                }
                .accentColor(.blue)
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .animation(.easeInOut, value: authViewModel.isLoggedIn)
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
}
