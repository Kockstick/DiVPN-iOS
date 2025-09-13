import SwiftUI

struct ShimmerModifier: ViewModifier {
    var isAnimated: Bool
    var color: Color
    
    @State private var gradientX: CGFloat = -1
    @State private var alpha: Double = 1.0
    @State private var overlayOpacity: Double = 0
    @State private var isRunning = false
    
    @ViewBuilder
    func body(content: Content) -> some View {
        let overlayView = gradient
            .opacity(overlayOpacity)       // плавный fade-in/out эффекта
            .compositingGroup()
            .allowsHitTesting(false)
        
        let base = content
        
        
        base
            .foregroundStyle(AnyShapeStyle(gradient))
            .onAppear {
                // Старт без рывков
                if isAnimated {
                    alpha = 0.5
                    overlayOpacity = 1
                    startShimmer(smooth: true)
                } else {
                    alpha = 1.0
                    overlayOpacity = 0
                    gradientX = -1
                    isRunning = false
                }
            }
            .onChange(of: isAnimated) { on in
                if on {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        alpha = 0.5
                        overlayOpacity = 1
                    }
                    startShimmer(smooth: true)
                } else {
                    // Мягкое выключение
                    withAnimation(.easeOut(duration: 0.25)) {
                        alpha = 1.0
                        overlayOpacity = 0
                    }
                    gradientX = -1
                    isRunning = false
                }
            }
    }
    
    private func startShimmer(smooth: Bool) {
        guard !isRunning else { return }
        isRunning = true
        
        // Старт не с края, а чуть внутри, чтобы не было «провала»
        gradientX = smooth ? -0.2 : -1
        
        // Микрозадержка даёт opacity успеть подняться
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                gradientX = 2
            }
        }
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                color.opacity(alpha),
                color.opacity(1),
                color.opacity(alpha)
            ],
            startPoint: UnitPoint(x: gradientX, y: 0),
            endPoint:   UnitPoint(x: gradientX - 1, y: 0)
        )
    }
}

extension View {
    func shimmer(_ isAnimated: Bool,
                 color: Color = Color("TextPrimary")) -> some View {
        modifier(ShimmerModifier(isAnimated: isAnimated, color: color))
    }
}
