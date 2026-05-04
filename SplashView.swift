import SwiftUI

struct SplashView: View {
    @Binding var isActive: Bool
    @State private var boltScale: CGFloat = 0.5
    @State private var boltOpacity: Double = 0.0
    @State private var circleScale: CGFloat = 0.0
    @State private var circleOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // The Expanding Shockwave Ring
            Circle()
                .stroke(Color.cyan, lineWidth: 5)
                .scaleEffect(circleScale)
                .opacity(circleOpacity)
            
            // The Main Bolt
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(color: .cyan, radius: 20)
                
                Text("JOLT")
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            .scaleEffect(boltScale)
            .opacity(boltOpacity)
        }
        .onAppear {
            // 1. Bolt fades in
            withAnimation(.easeIn(duration: 0.5)) {
                boltOpacity = 1.0
                boltScale = 1.0
            }
            
            // 2. The "Jolt" Impact (Shockwave)
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                boltScale = 1.5 // Pulse up
                circleScale = 5.0 // Ring explodes outward
                circleOpacity = 0.0
            }
            
            // 3. Shrink back and exit
            withAnimation(.spring().delay(0.8)) {
                boltScale = 0.0 // Zoom away
            }
            
            // 4. Tell RootView we are done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    isActive = false
                }
            }
            
            // Haptic Impact
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}
