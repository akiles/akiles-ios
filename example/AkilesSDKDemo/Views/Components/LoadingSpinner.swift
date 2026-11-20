import SwiftUI

// iOS 13 Compatible Loading Spinner Component
struct LoadingSpinner: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 0.7)
            .stroke(Color.blue, lineWidth: 2)
            .frame(width: 16, height: 16)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(
                Animation.linear(duration: 1)
                    .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}