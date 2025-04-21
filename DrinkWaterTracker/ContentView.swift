import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @StateObject private var authViewModel = DrinkWaterTracker.AuthViewModel()
    @StateObject private var waterViewModel = DrinkWaterTracker.WaterViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                NavigationView {
                    HomeView(authViewModel: authViewModel, waterViewModel: waterViewModel)
                        .navigationBarHidden(true)
                }
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
