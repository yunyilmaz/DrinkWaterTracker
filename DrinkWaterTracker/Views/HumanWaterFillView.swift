import SwiftUI

struct HumanWaterFillView: View {
    var progress: Double // 0.0 to 1.0
    var totalAmount: Int
    var targetAmount: Int
    
    @State private var waveOffset = 0.0
    @State private var animatedProgress: Double = 0.0
    @State private var shimmer = false // For shimmer effect
    
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
                    
                    // Water fill clipped to human shape
                    ZStack(alignment: .bottom) {
                        // Animated wave effect - starts from bottom to ensure it begins at feet
                        WaveShape(amplitude: 5, frequency: 0.3, phase: waveOffset)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .blue.opacity(0.9)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: geometry.size.height) // Full height for the wave shape
                            .offset(y: geometry.size.height * (1 - animatedProgress)) // Use animatedProgress here
                            // Apply shimmer effect as an overlay rather than within the fill
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
                                    .frame(height: geometry.size.height * animatedProgress)
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
                    
                    // Progress percentage
                    Text("\(Int(min(progress * 100, 100)))%")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.top, 5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .onAppear {
                // Start wave animation
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    waveOffset = 2 * .pi
                }
                
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
        .accessibilityLabel("Water intake progress: \(Int(min(progress * 100, 100)))%")
        .accessibilityValue("\(totalAmount) ml of \(targetAmount) ml")
    }
}

// Wave shape for water animation
struct WaveShape: Shape {
    var amplitude: Double // Height of the wave
    var frequency: Double // How many waves fit in the view
    var phase: Double // Animation phase
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midHeight = rect.height / 2
        let width = rect.width
        
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let sine = sin(2 * .pi * (relativeX * frequency + phase))
            let y = midHeight + sine * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

// Helper extension for gradient with fractional onset
extension LinearGradient {
    init(gradient: Gradient, startPoint: UnitPoint, startOnsetFraction: CGFloat = 0, endPoint: UnitPoint) {
        self.init(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
    }
}

#Preview {
    HumanWaterFillView(progress: 0.65, totalAmount: 1300, targetAmount: 2000)
        .previewLayout(.sizeThatFits)
        .padding()
        .preferredColorScheme(.light)
}
