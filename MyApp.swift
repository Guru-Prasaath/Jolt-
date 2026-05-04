import SwiftUI

@main
struct MyApp: App {
    // Save state so user doesn't see onboarding every time
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    // Phase 1: The High-Energy Splash Screen
                    SplashView(isActive: $showSplash)
                        .zIndex(2) // Ensures it sits on top of everything
                } else {
                    if hasOnboarded {
                        // Phase 3: The Main App
                        MainView()
                            .transition(.opacity)
                    } else {
                        // Phase 2: Onboarding (First time users only)
                        OnboardingView(onboardingComplete: $hasOnboarded)
                            .transition(.opacity)
                    }
                }
            }
            // Smooth transitions between phases
            .animation(.easeInOut, value: showSplash)
            .animation(.easeInOut, value: hasOnboarded)
        }
    }
}
