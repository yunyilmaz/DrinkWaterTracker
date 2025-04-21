import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        }
    }
}

protocol AuthServiceProtocol {
    func authenticate(username: String, password: String) -> Result<Void, AuthError>
}

class AuthService: AuthServiceProtocol {
    // In a real app, this would call an API or use Firebase/Auth0, etc.
    func authenticate(username: String, password: String) -> Result<Void, AuthError> {
        // Demo authentication logic - in a real app, never hardcode credentials
        if username == "admin" && password == "password" {
            return .success(())
        } else {
            return .failure(.invalidCredentials)
        }
    }
}

// Mock implementation for preview and testing
class MockAuthService: AuthServiceProtocol {
    var shouldSucceed = true
    
    func authenticate(username: String, password: String) -> Result<Void, AuthError> {
        if shouldSucceed {
            return .success(())
        } else {
            return .failure(.invalidCredentials)
        }
    }
}
