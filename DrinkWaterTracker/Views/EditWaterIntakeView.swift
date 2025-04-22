import SwiftUI

struct EditWaterIntakeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var waterViewModel: WaterViewModel
    var intake: WaterIntake
    
    @State private var amount: String = ""
    @State private var selectedPreset: Double?
    
    let presets: [Double] = [100, 200, 250, 300, 500, 750, 1000]
    
    init(waterViewModel: WaterViewModel, intake: WaterIntake) {
        self.waterViewModel = waterViewModel
        self.intake = intake
        self._amount = State(initialValue: "\(Int(intake.amount))")
    }
    
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
                    Button("Update Water Intake") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            waterViewModel.updateWaterIntake(id: intake.id, amount: amountValue)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil || Double(amount)! <= 0)
                    
                    Button(role: .destructive, action: {
                        if let index = waterViewModel.waterIntakes.firstIndex(where: { $0.id == intake.id }) {
                            waterViewModel.removeWaterIntake(at: IndexSet([index]))
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Delete Water Intake")
                    }
                }
            }
            .navigationTitle("Edit Water")
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

#Preview {
    EditWaterIntakeView(
        waterViewModel: WaterViewModel(),
        intake: WaterIntake(amount: 250)
    )
}
