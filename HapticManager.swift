//
//  File.swift
//  Jolt
//
//  Created by user@5 on 19/02/26.
//

import CoreHaptics
import UIKit

// ADD THIS LINE BELOW 👇
@MainActor
class HapticManager: ObservableObject {
    static let shared = HapticManager()
    private var engine: CHHapticEngine?
    
    init() {
        prepareHaptics()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic Engine Error: \(error.localizedDescription)")
        }
    }
    
    // The "Revving" Effect (Heartbeat building up)
    func playBuildUp(intensity: Float, sharpness: Float) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        // Ensure intensity/sharpness are between 0 and 1
        let clampedIntensity = min(max(intensity, 0), 1)
        let clampedSharpness = min(max(sharpness, 0), 1)
        
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: clampedIntensity)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: clampedSharpness)
        
        // Continuous event (rumble)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensityParam, sharpnessParam], relativeTime: 0, duration: 0.1)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
    
    // The "Explosion" when they succeed
    func playSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
