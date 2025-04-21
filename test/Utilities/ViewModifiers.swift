import SwiftUI

// MARK: - View Modifiers
struct CustomButtonStyle: ViewModifier {
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding(.horizontal)
    }
}

// Creating an extension makes your custom style more SwiftUI-like
extension View {
    func customButton(backgroundColor: Color) -> some View {
        self.modifier(CustomButtonStyle(backgroundColor: backgroundColor))
    }
}
