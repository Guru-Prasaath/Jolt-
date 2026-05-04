//
//  CommitView.swift
//  Jolt
//
//  Created by user@5 on 27/02/26.
//

import SwiftUI
import CoreMotion

struct CommitView: View {
    // Motion Manager
    @StateObject private var motion = MotionManager()
    
    // Game State
    @State private var progress: CGFloat = 0.0
    @State private var isLockedIn = false
    @State private var orbOffset: CGSize = .zero
    @State private var isStable = false
    
    // Visuals
    let sensitivity: Double = 150.0 // Higher = Harder to keep still
    
    var body: some View {
        ZStack {
            // 1. Background (Reactive to Stability)
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Subtle background glow that turns red when unstable
            RadialGradient(
                gradient: Gradient(colors: [
                    isLockedIn ? .green : (isStable ? .cyan : .red),
                    .black
                ]),
                center: .center,
                startRadius: 5,
                endRadius: 300
            )
            .opacity(0.2)
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 0.2), value: isStable)
            
            if isLockedIn {
                // SUCCESS STATE
                VStack(spacing: 20) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                        .shadow(color: .green, radius: 20)
                    
                    Text("FOCUS LOCKED")
                        .font(.system(size: 30, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("Your mind is now steady.")
                        .foregroundColor(.gray)
                    
                    Button("RESET") {
                        withAnimation {
                            isLockedIn = false
                            progress = 0.0
                        }
                    }
                    .padding(.top, 40)
                    .foregroundColor(.white.opacity(0.5))
                }
                .transition(.scale)
                
            } else {
                // GAME STATE
                VStack {
                    Text(isStable ? "HOLD STEADY..." : "TOO SHAKY")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(isStable ? .cyan : .red)
                        .padding(.top, 60)
                        .shadow(color: isStable ? .cyan : .red, radius: 10)
                    
                    Spacer()
                    
                    ZStack {
                        // 1. The Target Zone (Center Ring)
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: 150, height: 150)
                        
                        // 2. Progress Ring (Fills up when stable)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.cyan,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 150, height: 150)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: progress)
                        
                        // 3. The Floating Orb (Controlled by Gyro)
                        Circle()
                            .fill(
                                RadialGradient(colors: [.white, isStable ? .cyan : .red], center: .center, startRadius: 5, endRadius: 30)
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: isStable ? .cyan : .red, radius: 10)
                            .offset(orbOffset) // MOVES WITH PHONE TILT
                            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5), value: orbOffset)
                    }
                    
                    Spacer()
                    
                    Text("Balance the orb in the center\nto sync your focus.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            motion.startUpdates()
        }
        .onDisappear {
            motion.stopUpdates()
        }
        .onReceive(motion.$pitch) { _ in
            updateGameLogic()
        }
    }
    
    func updateGameLogic() {
        if isLockedIn { return }
        
        // 1. Calculate Orb Movement based on Tilt
        // We amplify the tilt so small movements look big
        let xOffset = CGFloat(motion.roll * sensitivity)
        let yOffset = CGFloat(motion.pitch * sensitivity)
        
        orbOffset = CGSize(width: xOffset, height: yOffset)
        
        // 2. Determine Stability
        // Stability Zone: The orb is roughly in the center (offset < 50)
        let distanceFromCenter = sqrt(pow(xOffset, 2) + pow(yOffset, 2))
        let wasStable = isStable
        isStable = distanceFromCenter < 50
        
        // Haptic Feedback when crossing threshold
        if isStable != wasStable {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        // 3. Update Progress
        if isStable {
            // Fill up bar (takes about 4-5 seconds)
            progress += 0.005
            
            // Continuous subtle vibration to indicate tension
            if Int(progress * 100) % 10 == 0 {
                let generator = UISelectionFeedbackGenerator()
                generator.selectionChanged()
            }
            
            if progress >= 1.0 {
                lockIn()
            }
        } else {
            // Decay progress rapidly if shaky
            progress -= 0.02
            if progress < 0 { progress = 0 }
        }
    }
    
    func lockIn() {
        isLockedIn = true
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// --- MOTION MANAGER CLASS ---
class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    // Published properties to update the UI
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    func startUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                
                // Update Pitch and Roll
                self.pitch = data.attitude.pitch
                self.roll = data.attitude.roll
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
}
