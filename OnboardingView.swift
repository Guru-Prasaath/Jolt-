import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingComplete: Bool
    @State private var currentPage = 0
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(white: 0.05)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            TabView(selection: $currentPage) {
                // SLIDE 1: The Problem
                OnboardingPage(
                    imageName: "brain.head.profile",
                    title: "PARALYSIS",
                    description: "Your brain is stuck in a loop of overthinking. You need a physical shock to break out."
                )
                .tag(0)
                
                // SLIDE 2: The Action
                OnboardingPage(
                    imageName: "bolt.fill",
                    title: "VISCERAL ACTION",
                    description: "Scrub to generate heat. Tap to shatter your doubts. Turn mental friction into kinetic energy."
                )
                .tag(1)
                
                // SLIDE 3: The Void Anchor (with Glass Button)
                VStack {
                    Spacer()
                    
                    Image(systemName: "waveform.path.ecg")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .foregroundColor(.cyan)
                        .padding(.bottom, 30)
                        .shadow(color: .cyan.opacity(0.6), radius: 30)
                    
                    Text("TOTAL STILLNESS")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Chaos kills focus. Balance the Void Anchor using your phone's gyroscope to prove your mind is steady.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // --- THE GLASS BUTTON ---
                    Button(action: {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        
                        withAnimation {
                            onboardingComplete = true
                        }
                    }) {
                        HStack(spacing: 15) {
                            Text("ENTER JOLT")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .kerning(1.5) // Spacing out letters looks more premium
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial) // The Blur Effect
                        .background(
                            // Subtle Cyan Tint behind the blur
                            LinearGradient(
                                colors: [Color.cyan.opacity(0.3), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            // The Icy White Border
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .cyan.opacity(0.4), radius: isPulsing ? 20 : 10, x: 0, y: 10)
                        .scaleEffect(isPulsing ? 1.02 : 1.0)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Page Dots
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Color.cyan : Color.white.opacity(0.2))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 25) // Below the button area
            }
        }
    }
}

// Helper View
struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .foregroundColor(.cyan)
                .padding(.bottom, 30)
                .shadow(color: .cyan.opacity(0.5), radius: 25)
            
            Text(title)
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 30)
                .padding(.top, 10)
            
            Spacer()
        }
        .padding(.bottom, 60) // Lift content up slightly
    }
}
