import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .ignite
    
    enum Tab {
        case ignite
        case smash
        case commit
    }
    
    init() {
        // Hide default tab bar so we can use our custom docked one
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: - 1. CONTENT LAYER
            Group {
                switch selectedTab {
                case .ignite:
                    ContentView()
                case .smash:
                    SmashView()
                case .commit:
                    CommitView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - 2. STANDARD iOS DOCKED TAB BAR
            VStack(spacing: 0) {
                // Thin separator line at the top (Standard iOS detail)
                Divider()
                    .background(Color.white.opacity(0.15))
                
                HStack(spacing: 0) {
                    // TAB 1: IGNITE
                    StandardTabButton(
                        icon: "flame.fill",
                        text: "Ignite",
                        isActive: selectedTab == .ignite,
                        activeColor: .orange
                    ) {
                        switchTab(to: .ignite)
                    }
                    
                    // TAB 2: BREAK
                    StandardTabButton(
                        icon: "hammer.fill", // Hammer fits the "Smash" theme perfectly
                        text: "Break",
                        isActive: selectedTab == .smash,
                        activeColor: .cyan
                    ) {
                        switchTab(to: .smash)
                    }
                    
                    // TAB 3: COMMIT
                    StandardTabButton(
                        icon: "waveform.path.ecg",
                        text: "Commit",
                        isActive: selectedTab == .commit,
                        activeColor: .green
                    ) {
                        switchTab(to: .commit)
                    }
                }
                .padding(.top, 10) // Standard top padding
                .padding(.bottom, 25) // Safe Area for Home Indicator
                .background(.ultraThinMaterial) // Native iOS Frosted Glass
            }
        }
        .edgesIgnoringSafeArea(.bottom) // Allows the bar to sit behind the home indicator
        .preferredColorScheme(.dark)
    }
    
    // MARK: - LOGIC
    func switchTab(to tab: Tab) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        // No spring animation for standard tabs - instant snap feels more native
        selectedTab = tab
    }
}

// MARK: - STANDARD TAB COMPONENT
struct StandardTabButton: View {
    let icon: String
    let text: String
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Icon (Standard iOS Size: ~24pt)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? activeColor : .gray)
                    // Add a subtle glow only when active
                    .shadow(color: isActive ? activeColor.opacity(0.6) : .clear, radius: 10)
                
                // Text Label (Standard iOS Size: ~10pt)
                Text(text)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isActive ? activeColor : .gray)
            }
            .frame(maxWidth: .infinity) // Each button takes equal width
            .contentShape(Rectangle()) // Tappable area fills the space
        }
    }
}
