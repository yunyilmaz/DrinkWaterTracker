import XCTest

final class LoginUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLoginFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Enter credentials
        let usernameField = app.textFields["usernameField"]
        XCTAssertTrue(usernameField.exists)
        usernameField.tap()
        usernameField.typeText("admin")
        
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("password")
        
        // Tap login button
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
        
        // Verify we're logged in
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 2))
        
        // Test logout
        logoutButton.tap()
        XCTAssertTrue(loginButton.waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testInvalidLogin() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Enter incorrect credentials
        let usernameField = app.textFields["usernameField"]
        usernameField.tap()
        usernameField.typeText("wrong")
        
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("wrongpass")
        
        // Tap login button
        let loginButton = app.buttons["loginButton"]
        loginButton.tap()
        
        // Verify error message appears
        let errorMessage = app.staticTexts["errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2))
        XCTAssertEqual(errorMessage.label, "Invalid username or password")
    }
}
