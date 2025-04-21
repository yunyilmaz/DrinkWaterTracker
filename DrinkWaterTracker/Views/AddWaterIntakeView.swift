import SwiftUI

struct AddWaterIntakeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var waterViewModel: WaterViewModel
    
    @State private var amount: String = ""
    @State private var selectedPreset: Double?
    
    let presets: [Double] = [100, 200, 250, 300, 500, 750, 1000]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount (ml)")) {
                    TextField("Enter amount", text: $amount)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Quick Presets")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(presets, id: \.self) { preset in
                                Button(action: {
                                    selectedPreset = preset
                                    amount = "\(Int(preset))"
                                }) {
                                    VStack {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 25))
                                            .foregroundColor(.blue)
                                        Text("\(Int(preset)) ml")
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(selectedPreset == preset ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                Section {
                    Button("Add Water Intake") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            waterViewModel.addWaterIntake(amount: amountValue)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0)
                }
            }
            .navigationTitle("Add Water")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
