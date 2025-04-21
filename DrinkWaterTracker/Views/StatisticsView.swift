import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var waterViewModel: WaterViewModel
    @State private var selectedTimeframe: Timeframe = .week
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Chart view would go here using the Swift Charts framework
                
                // Stats summary
                VStack(alignment: .leading, spacing: 10) {
                    StatRow(title: "Average Daily Intake", value: "\(Int(waterViewModel.averageIntake(for: selectedTimeframe))) ml")
                    StatRow(title: "Goal Achievement Rate", value: "\(Int(waterViewModel.achievementRate(for: selectedTimeframe) * 100))%")
                    StatRow(title: "Best Day", value: waterViewModel.bestDay(for: selectedTimeframe))
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Statistics")
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}