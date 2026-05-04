import SwiftUI

// 1. SHAKE EFFECT
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

// 2. PARTICLE MODEL
struct Spark: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
}

struct ContentView: View {
    // Game variables
    @State private var heatLevel: CGFloat = 0.0
    @State private var isIgnited = false
    @State private var lastDragPosition: CGFloat = 0.0
    
    // Juice Variables
    @State private var sparks: [Spark] = []
    @State private var shakeAmount: CGFloat = 0.0
    
    // The "Cooling" timer
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 1. DYNAMIC BACKGROUND
            RadialGradient(
                gradient: Gradient(colors: [
                    heatColor(),
                    Color.black
                ]),
                center: .center,
                startRadius: 5 + (heatLevel * 2),
                endRadius: 100 + (heatLevel * 4)
            )
            .edgesIgnoringSafeArea(.all)
            
            // 2. SPARKS LAYER
            ForEach(sparks) { spark in
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8 * spark.scale, height: 8 * spark.scale)
                    .position(x: spark.x, y: spark.y)
                    .opacity(spark.opacity)
            }
            
            VStack {
                // 3. TITLE TEXT
                Text(isIgnited ? "SYSTEM ONLINE" : "REV THE ENGINE")
                    .font(.system(size: 28, weight: .black, design: .monospaced))
                    .foregroundColor(isIgnited ? .white : .gray)
                    .shadow(color: heatColor(), radius: 10)
                    .padding(.top, 60)
                    .modifier(Shake(animatableData: shakeAmount))
                
                Text(isIgnited ? "Focus Protocols Active" : "Scrub aggressively to build charge")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 10)
                
                Spacer()
                
                // 4. THE REACTOR CORE
                ZStack {
                    // Outer Ring
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 220, height: 220)
                    
                    // Heat Ring
                    Circle()
                        .trim(from: 0.0, to: heatLevel / 100)
                        .stroke(
                            AngularGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .white]), center: .center),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                        .shadow(color: .orange, radius: heatLevel / 3)
                        .animation(.linear(duration: 0.1), value: heatLevel)
                    
                    // Center Button
                    Circle()
                        .fill(LinearGradient(colors: [Color(white: 0.1), Color.black], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "bolt.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60)
                                .foregroundColor(heatLevel > 80 ? .white : .gray)
                                .shadow(color: .white, radius: heatLevel > 80 ? 20 : 0)
                        )
                        .modifier(Shake(animatableData: shakeAmount))
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if isIgnited { return }
                            let dragDistance = abs(value.translation.width - lastDragPosition)
                            lastDragPosition = value.translation.width
                            
                            heatLevel += dragDistance * 0.8
                            if heatLevel > 100 { heatLevel = 100 }
                            
                            createSpark(at: value.location)
                            
                            if dragDistance > 2 {
                                HapticManager.shared.playBuildUp(intensity: Float(heatLevel/100), sharpness: Float(heatLevel/100))
                            }
                        }
                        .onEnded { _ in lastDragPosition = 0.0 }
                )
                
                Spacer()
                
                // 5. NEW HUD-STYLE PERCENTAGE (FIXED PADDING)
                HStack(spacing: 0) {
                    Text("\(Int(heatLevel))")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Text("%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .baselineOffset(15)
                        .opacity(0.7)
                }
                .foregroundColor(heatColor())
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(heatColor().opacity(0.5), lineWidth: 2)
                )
                .shadow(color: heatColor().opacity(0.6), radius: 10)
                .scaleEffect(isIgnited ? 1.2 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: heatLevel)
                .modifier(Shake(animatableData: shakeAmount))
                // --- FIXED LINE BELOW ---
                .padding(.bottom, 100) // Increased to clear the custom tab bar
            }
        }
        .onReceive(timer) { _ in updatePhysics() }
    }
    
    // --- LOGIC HELPERS ---
    
    func heatColor() -> Color {
        if isIgnited { return .white }
        if heatLevel < 30 { return .blue }
        if heatLevel < 60 { return .orange }
        return .red
    }
    
    func createSpark(at location: CGPoint) {
        guard heatLevel > 10 else { return }
        let randomX = CGFloat.random(in: -20...20)
        let randomY = CGFloat.random(in: -20...20)
        let center = UIScreen.main.bounds.width / 2
        let spark = Spark(x: center + randomX, y: UIScreen.main.bounds.height/2 + 100 + randomY)
        sparks.append(spark)
        if sparks.count > 20 { sparks.removeFirst() }
    }
    
    func updatePhysics() {
        if isIgnited { return }
        if heatLevel > 0 {
            heatLevel -= 1.0
            if heatLevel < 0 { heatLevel = 0 }
        }
        if heatLevel > 50 {
            withAnimation(.default) {
                shakeAmount = CGFloat.random(in: -5...5) * (heatLevel / 100)
            }
        } else { shakeAmount = 0 }
        
        for index in sparks.indices {
            sparks[index].y += 5
            sparks[index].opacity -= 0.1
            sparks[index].scale -= 0.05
        }
        sparks.removeAll { $0.opacity <= 0 }
        
        if heatLevel >= 100 { triggerIgnition() }
    }
    
    func triggerIgnition() {
        isIgnited = true
        heatLevel = 100
        shakeAmount = 0
        HapticManager.shared.playSuccess()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                isIgnited = false
                heatLevel = 0
            }
        }
    }
}
