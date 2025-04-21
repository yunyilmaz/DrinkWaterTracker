import SwiftUI

// MARK: - Common UI Components

struct PrimaryButtonStyle: ViewModifier {
    let backgroundColor: Color
    let isDisabled: Bool
    
    init(backgroundColor: Color, isDisabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isDisabled = isDisabled
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray : backgroundColor)
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding(.horizontal)
            .opacity(isDisabled ? 0.7 : 1.0)
    }
}

extension View {
    func primaryButton(color: Color, disabled: Bool = false) -> some View {
        self.modifier(PrimaryButtonStyle(backgroundColor: color, isDisabled: disabled))
    }
}

// MARK: - Common Formatters

struct Formatters {
    static let volumeFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()
}

// MARK: - Accessibility Helpers

extension View {
    func accessibleAction(label: String, _ action: @escaping () -> Void) -> some View {
        self
            .accessibilityAction(named: Text(label)) {
                action()
            }
    }
}
