import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @FocusState private var focusField: Field?
    
    enum Field: Hashable {
        case username, password
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login")
                .font(.largeTitle)
                .bold()
                .accessibilityHeading(.h1)
            
            TextField("Username", text: $authViewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focusField, equals: .username)
                .submitLabel(.next)
                .accessibilityIdentifier("usernameField")
            
            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .focused($focusField, equals: .password)
                .submitLabel(.go)
                .accessibilityIdentifier("passwordField")
                .onSubmit {
                    authViewModel.login()
                }
            
            Toggle("Remember Username", isOn: $authViewModel.rememberUsername)
                .padding(.horizontal)
                .onChange(of: authViewModel.rememberUsername) { newValue in
                    authViewModel.updateRememberUsername(newValue)
                }
            
            if !authViewModel.errorMessage.isEmpty {
                Text(authViewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .accessibilityIdentifier("errorMessage")
            }
            
            Button(action: authViewModel.login) {
                Text("Sign In")
            }
            .customButton(backgroundColor: .blue)
            .accessibilityIdentifier("loginButton")
        }
        .padding()
        .onAppear {
            // Set initial focus to appropriate field
            focusField = authViewModel.username.isEmpty ? .username : .password
        }
        // Handle tab and return keys for better form navigation
        .onSubmit {
            switch focusField {
            case .username:
                focusField = .password
            case .password:
                authViewModel.login()
            default:
                break
            }
        }
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel())
}
