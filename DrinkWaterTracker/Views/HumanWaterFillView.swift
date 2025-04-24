import SwiftUI

struct HumanWaterFillView: View {
    var progress: Double // 0.0 to 1.0
    var totalAmount: Int
    var targetAmount: Int
    
    @State private var animatedProgress: Double = 0.0
    @State private var shimmer = false // For shimmer effect
    
    // Compute actual progress percentage without capping
    private var actualPercentage: Int {
        Int(progress * 100)
    }
    
    // Compute bonus percentage
    private var bonusPercentage: Int {
        max(0, actualPercentage - 100)
    }
    
    // Check if we have a bonus
    private var hasBonus: Bool {
        progress > 1.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 20) {
                // Left side - Human figure with animation
                ZStack(alignment: .bottom) {
                    // Single human silhouette with border
                    Image(systemName: "figure.stand")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.clear)
                        .background(
                            Image(systemName: "figure.stand")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray.opacity(0.5)) // Increased opacity for better contrast
                        )
                        .frame(width: geometry.size.width * 0.4)
                    
                    // Water fill clipped to human shape - simple rectangle fill instead of wave
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.9), .blue]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: geometry.size.height * min(animatedProgress, 1.0)) // Cap the filled height at 100%
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            // Apply shimmer effect as an overlay
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(
                                        colors: [.clear, .white.opacity(0.2), .clear]
                                    ),
                                    startPoint: UnitPoint(x: shimmer ? 0 : 1, y: shimmer ? 0 : 1),
                                    endPoint: UnitPoint(x: shimmer ? 1 : 0, y: shimmer ? 1 : 0)
                                )
                                .blendMode(.overlay)
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .mask(
                        Image(systemName: "figure.stand")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geometry.size.width * 0.4)
                    )
                    // Add a slight glow effect to highlight the water
                    .overlay(
                        Image(systemName: "figure.stand")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.blue.opacity(0.3))
                            .frame(width: geometry.size.width * 0.4)
                            .mask(
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: geometry.size.height * min(animatedProgress, 1.0))
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                            )
                            .blur(radius: 3)
                    )
                }
                .frame(maxWidth: geometry.size.width * 0.5)
                
                // Right side - Text display
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(totalAmount) ml")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary) 
                    
                    Text("of \(targetAmount) ml")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Progress percentage - now showing actual percentage even if over 100%
                    Text("\(actualPercentage)%")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                    
                    // Bonus indicator when over 100%
                    if hasBonus {
                        Text("Bonus: +\(bonusPercentage)%")
                            .font(.headline)
                            .foregroundColor(.green)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.2))
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .onAppear {
                // Animate to initial progress value with delay
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedProgress = progress
                }
                
                // Add shimmer animation
                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    shimmer = true
                }
            }
            .onChange(of: progress) { oldValue, newValue in
                // Animate progress changes
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedProgress = newValue
                }
            }
        }
        .frame(height: 280)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Water intake progress: \(actualPercentage)%\(hasBonus ? ", Bonus: +\(bonusPercentage)%" : "")")
        .accessibilityValue("\(totalAmount) ml of \(targetAmount) ml")
    }
}

#Preview {
    VStack(spacing: 20) {
        HumanWaterFillView(progress: 0.65, totalAmount: 1300, targetAmount: 2000)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("65% Progress")
        
        HumanWaterFillView(progress: 1.0, totalAmount: 2000, targetAmount: 2000)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("100% Progress")
        
        HumanWaterFillView(progress: 1.25, totalAmount: 2500, targetAmount: 2000)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("125% Progress with Bonus")
    }
    .preferredColorScheme(.light)
}
