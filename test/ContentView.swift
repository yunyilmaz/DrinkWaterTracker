import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @StateObject private var authViewModel = test.AuthViewModel()
    @StateObject private var waterViewModel = test.WaterViewModel()
    
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
