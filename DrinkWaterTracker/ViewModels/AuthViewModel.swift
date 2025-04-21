import Foundation
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    @Published var rememberUsername: Bool = false
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        // Check if user is already logged in
        isLoggedIn = userDefaults.bool(forKey: "isLoggedIn")
        // Load remembered username if enabled
        if userDefaults.bool(forKey: "rememberUsername") {
            username = userDefaults.string(forKey: "savedUsername") ?? ""
            rememberUsername = true
        }
    }
    
    func login() {
        // Validation
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        
        // Save username if remember is enabled
        if rememberUsername {
            userDefaults.set(username, forKey: "savedUsername")
        }
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoggedIn = true
            self.userDefaults.set(true, forKey: "isLoggedIn")
            self.errorMessage = ""
            self.password = "" // Clear password for security
        }
    }
    
    func logout() {
        isLoggedIn = false
        userDefaults.set(false, forKey: "isLoggedIn")
        password = ""
        if !rememberUsername {
            username = ""
        }
    }
    
    func updateRememberUsername(_ remember: Bool) {
        rememberUsername = remember
        userDefaults.set(remember, forKey: "rememberUsername")
        if !remember {
            userDefaults.removeObject(forKey: "savedUsername")
            username = ""
        }
    }
}
