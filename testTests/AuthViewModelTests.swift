import Testing
@testable import test

struct AuthViewModelTests {
    
    @Test func testSuccessfulLogin() async throws {
        // Setup
        let mockService = MockAuthService()
        mockService.shouldSucceed = true
        
        let viewModel = AuthViewModel(authService: mockService)
        viewModel.username = "admin"
        viewModel.password = "password123"
        
        // Act
        viewModel.login()
        
        // Assert
        #expect(viewModel.isLoggedIn == true)
        #expect(viewModel.errorMessage.isEmpty)
        #expect(viewModel.password.isEmpty)
    }
    
    @Test func testFailedLogin() async throws {
        // Setup
        let mockService = MockAuthService()
        mockService.shouldSucceed = false
        
        let viewModel = AuthViewModel(authService: mockService)
        viewModel.username = "admin"
        viewModel.password = "password123"
        
        // Act
        viewModel.login()
        
        // Assert
        #expect(viewModel.isLoggedIn == false)
        #expect(!viewModel.errorMessage.isEmpty)
        #expect(viewModel.password.isEmpty)
    }
    
    @Test func testEmptyUsername() async throws {
        // Setup
        let viewModel = AuthViewModel()
        viewModel.username = ""
        viewModel.password = "password123"
        
        // Act
        viewModel.login()
        
        // Assert
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.errorMessage == "Username cannot be empty")
    }
    
    @Test func testEmptyPassword() async throws {
        // Setup
        let viewModel = AuthViewModel()
        viewModel.username = "admin"
        viewModel.password = ""
        
        // Act
        viewModel.login()
        
        // Assert
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.errorMessage == "Password cannot be empty")
    }
    
    @Test func testShortPassword() async throws {
        // Setup
        let viewModel = AuthViewModel()
        viewModel.username = "admin"
        viewModel.password = "12345"  // Less than 6 chars
        
        // Act
        viewModel.login()
        
        // Assert
        #expect(viewModel.isLoggedIn == false)
        #expect(viewModel.errorMessage == "Password must be at least 6 characters")
    }
    
    @Test func testLogout() async throws {
        // Setup
        let viewModel = AuthViewModel()
        viewModel.isLoggedIn = true
        
        // Act
        viewModel.logout()
        
        // Assert
        #expect(viewModel.isLoggedIn == false)
    }
}
