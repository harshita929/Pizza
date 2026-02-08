//
//  OnboardingView.swift
//  Tavolo
//
//  Unified liquid onboarding – cool neon grading + bounce
//

import SwiftUI

// ────────────────────────────────────────────────
// Unified Liquid Background (image-matched)
// ────────────────────────────────────────────────
struct UnifiedLiquidBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {

            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.07, blue: 0.14),
                    Color(red: 0.12, green: 0.08, blue: 0.24),
                    Color(red: 0.22, green: 0.10, blue: 0.38)
                ],
                startPoint: animate ? .topLeading : .bottomTrailing,
                endPoint: animate ? .bottomTrailing : .topLeading
            )

            RadialGradient(
                colors: [
                    Color(red: 0.38, green: 0.78, blue: 1.0).opacity(0.55),
                    .clear
                ],
                center: animate ? .topLeading : .topTrailing,
                startRadius: 40,
                endRadius: 420
            )
            .blendMode(.screen)

            RadialGradient(
                colors: [
                    Color(red: 0.78, green: 0.46, blue: 1.0).opacity(0.45),
                    .clear
                ],
                center: animate ? .bottomTrailing : .bottomLeading,
                startRadius: 60,
                endRadius: 500
            )
            .blendMode(.screen)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}

// ────────────────────────────────────────────────
// Main Onboarding View
// ────────────────────────────────────────────────
struct OnboardingView: View {

    @Binding var isOnboardingComplete: Bool

    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isRevealed = false
    @State private var bubbleOffsets: [Int: [CGFloat]] = [:]

    let pages: [OnboardingPage] = [
        .init(
            title: "Welcome to Tavolo",
            description: "Turn recipe inspiration into reality with smart lists and organization.",
            bubbles: ["person.fill", "fork.knife", "cart.fill", "book.fill", "flame.fill", "leaf.fill"]
        ),
        .init(
            title: "Magic Grocery Lists",
            description: "Paste any video link and watch ingredients appear instantly.",
            bubbles: ["sparkles", "wand.and.stars", "list.bullet.rectangle.portrait"]
        ),
        .init(
            title: "Your Kitchen Companion",
            description: "Save, search by ingredients, and cook with guided ease.",
            bubbles: ["stove.fill", "magnifyingglass", "heart.fill", "figure.arms.open"]
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {

            MorphingBlobBackground()

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageContent(
                        page: page,
                        pageIndex: index,
                        isFirstPage: index == 0,
                        isRevealed: $isRevealed,
                        dragOffset: $dragOffset,
                        bubbleOffsets: $bubbleOffsets,
                        onReveal: {
                            withAnimation(.spring(response: 0.55, dampingFraction: 0.68)) {
                                isRevealed = true
                                dragOffset = -UIScreen.main.bounds.height * 0.6
                                bubbleOffsets[index] = Array(repeating: 0, count: page.bubbles.count)
                            }
                        }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            if isRevealed || currentPage > 0 {
                Button {
                    withAnimation(.spring()) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            isOnboardingComplete = true
                        }
                    }
                } label: {
                    Text(currentPage == pages.count - 1 ? "Start Cooking" : "Continue")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .white.opacity(0.5), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            for (index, page) in pages.enumerated() {
                bubbleOffsets[index] = Array(repeating: 300, count: page.bubbles.count)
            }
        }
    }
}

// ────────────────────────────────────────────────
// Page Content (Bounce enabled)
// ────────────────────────────────────────────────
struct OnboardingPageContent: View {

    let page: OnboardingPage
    let pageIndex: Int
    let isFirstPage: Bool

    @Binding var isRevealed: Bool
    @Binding var dragOffset: CGFloat
    @Binding var bubbleOffsets: [Int: [CGFloat]]

    let onReveal: () -> Void

    @State private var bounceIn = false

    var body: some View {
        ZStack {

            if isRevealed || !isFirstPage {
                VStack(spacing: 44) {
                    Spacer()

                    Text(page.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .scaleEffect(bounceIn ? 1 : 0.85)
                        .opacity(bounceIn ? 1 : 0)
                        .animation(
                            .spring(response: 0.55, dampingFraction: 0.6),
                            value: bounceIn
                        )

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 48)
                        .scaleEffect(bounceIn ? 1 : 0.9)
                        .opacity(bounceIn ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7).delay(0.08),
                            value: bounceIn
                        )

                    BubblesRow(
                        bubbles: page.bubbles,
                        pageIndex: pageIndex,
                        bubbleOffsets: $bubbleOffsets,
                        shouldAnimateFromBottom: !isFirstPage
                    )

                    Spacer(minLength: 180)
                }
                .onAppear {
                    bounceIn = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        bounceIn = true
                    }
                }
            }

            if isFirstPage && !isRevealed {
                VStack {
                    Spacer()

                    Capsule()
                        .fill(.white)
                        .frame(width: 44, height: 7)
                        .symbolEffect(.bounce, value: dragOffset == 0)

                    Text("Swipe up to begin")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.top, 16)
                        .padding(.bottom, 56)
                }
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height < 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.predictedEndTranslation.height < -180 {
                                onReveal()
                            } else {
                                withAnimation(.spring()) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
        }
    }
}

// ────────────────────────────────────────────────
// Bubbles Row (Bounce + stagger)
// ────────────────────────────────────────────────
struct BubblesRow: View {

    let bubbles: [String]
    let pageIndex: Int
    @Binding var bubbleOffsets: [Int: [CGFloat]]
    let shouldAnimateFromBottom: Bool

    private var currentOffsets: Binding<[CGFloat]> {
        Binding(
            get: { bubbleOffsets[pageIndex] ?? Array(repeating: 300, count: bubbles.count) },
            set: { bubbleOffsets[pageIndex] = $0 }
        )
    }

    var body: some View {
        HStack(spacing: 24) {
            ForEach(Array(bubbles.enumerated()), id: \.offset) { index, symbol in
                Image(systemName: symbol)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .white.opacity(0.25), radius: 12)
                    )
                    .scaleEffect(currentOffsets.wrappedValue[index] == 0 ? 1 : 0.6)
                    .offset(y: currentOffsets.wrappedValue[index])
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.55)
                            .delay(Double(index) * 0.06),
                        value: currentOffsets.wrappedValue[index]
                    )
            }
        }
        .onAppear {
            if shouldAnimateFromBottom {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.25)) {
                    currentOffsets.wrappedValue = Array(repeating: 0, count: bubbles.count)
                }
            }
        }
    }
}

// ────────────────────────────────────────────────
// Data Model
// ────────────────────────────────────────────────
struct OnboardingPage {
    let title: String
    let description: String
    let bubbles: [String]
}

// ────────────────────────────────────────────────
// Preview
// ────────────────────────────────────────────────
#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
        .preferredColorScheme(.dark)
}
