import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("isOnboardingComplete") private var isOnboardingComplete = false
    @State private var selectedTab = 0
    
    var body: some View {
        if !isOnboardingComplete {
            OnboardingView(isOnboardingComplete: $isOnboardingComplete)
                .transition(.opacity.combined(with: .scale(scale: 1.1)))
        } else {
            TabView(selection: $selectedTab) {
                CookbookLibraryView()
                    .tabItem {
                        Label("Library", systemImage: "book.fill")
                    }
                    .tag(0)
                
                GroceryGeneratorView()
                    .tabItem {
                        Label("Magic List", systemImage: "wand.and.stars")
                    }
                    .tag(1)
            }
            .tint(DesignSystem.Colors.accent)
            .onAppear {
                // Set TabView appearance for Liquid Glass feel
                let appearance = UITabBarAppearance()
                appearance.configureWithDefaultBackground()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                UITabBar.appearance().scrollEdgeAppearance = appearance
                UITabBar.appearance().standardAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
