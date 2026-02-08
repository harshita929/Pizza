//
//  GroceryGeneratorView.swift
//  Tavolo
//
//  Created by Antigravity on 08/02/26.
//  Modernized 2026 version
//

import SwiftUI

struct GroceryGeneratorView: View {
    @State private var recipeUrl = ""
    @State private var isProcessing = false
    @State private var generatedItems: [GroceryItem] = []
    @State private var generatedRecipe: Recipe?
    @State private var showItems = false
    @State private var showRecipeSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Modern gradient background (subtle)
                LinearGradient(
                    colors: [Color(.systemCyan).opacity(0.12), Color(.systemPurple).opacity(0.08)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Optional very light noise / grain overlay (iOS 18+ style)
                // .overlay(NoiseBackground().opacity(0.06))
                
                VStack(spacing: 32) {
                    // Hero / Input Card – stronger glassmorphism
                    GlassCard(cornerRadius: 28) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Generate Grocery List")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                            
                            Text("Paste any recipe video or blog link")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                            
                            // Modern TextField with floating placeholder feel
                            FloatingTextField(
                                placeholder: "TikTok, YouTube, Instagram, Blog…",
                                text: $recipeUrl
                            )
                            
                            // Sample chip – smaller, more elegant
                            Button {
                                recipeUrl = "https://www.tiktok.com/@eitan/video/recipe123"
                            } label: {
                                Text("Try sample link")
                                    .font(.caption.bold())
                                    .foregroundStyle(DesignSystem.Colors.accent)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(DesignSystem.Colors.accent.opacity(0.12))
                                    )
                            }
                            .buttonStyle(.plain)
                            
                            // Primary CTA – neumorphic / glowing accent
                            Button(action: generateList) {
                                HStack(spacing: 12) {
                                    if isProcessing {
                                        ProgressView()
                                            .controlSize(.regular)
                                            .tint(.white)
                                        Text("Analyzing recipe…")
                                    } else {
                                        Image(systemName: "wand.and.stars")
                                            .symbolEffect(.pulse, options: .repeating)
                                        Text("Generate List")
                                    }
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background {
                                    if recipeUrl.isEmpty || isProcessing {
                                        Capsule().fill(.gray.opacity(0.25))
                                    } else {
                                        Capsule()
                                            .fill(DesignSystem.Colors.accent.gradient)
                                            .shadow(color: DesignSystem.Colors.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                                    }
                                }
                                .foregroundStyle(.white)
                            }
                            .disabled(recipeUrl.isEmpty || isProcessing)
                            .buttonStyle(.plain)
                        }
                        .padding(24)
                    }
                    .padding(.horizontal, 20)
                    
                    // Content area
                    if isProcessing {
                        VStack(spacing: 24) {
                            LottieLikeAnimation()
                                .frame(width: 180, height: 180)
                            
                            Text("Extracting ingredients...")
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    } else if !generatedItems.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                HStack {
                                    Text("Your Grocery List")
                                        .font(.title2.bold())
                                        .foregroundStyle(.white)
                                    
                                    Spacer()
                                    
                                    if generatedRecipe != nil {
                                        Button {
                                            showRecipeSheet = true
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: "fork.knife")
                                                Text("View Recipe")
                                            }
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(DesignSystem.Colors.accent.gradient)
                                            .clipShape(Capsule())
                                        }
                                        .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .padding(.horizontal, 8)
                                
                                ForEach(Array(generatedItems.enumerated()), id: \.element.id) { index, item in
                                    GroceryRow(item: item)
                                        .opacity(showItems ? 1 : 0)
                                        .offset(y: showItems ? 0 : 30)
                                        .animation(
                                            .spring(response: 0.45, dampingFraction: 0.78)
                                            .delay(Double(index) * 0.07),
                                            value: showItems
                                        )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .scrollIndicators(.hidden)
                    } else {
                        // Modern empty state
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "cart.circle.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(DesignSystem.Colors.accent.gradient)
                                .symbolEffect(.bounce, value: recipeUrl)
                            
                            Text("Ready when you are")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("Paste a recipe link above to get started")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Magic Grocery")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $generatedRecipe) { recipe in
                RecipeDetailView(recipe: recipe) {
                    generatedRecipe = nil
                }
            }
            .toolbar {
                if !generatedItems.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear All") {
                            withAnimation(.spring()) {
                                generatedItems = []
                                generatedRecipe = nil
                                showItems = false
                                recipeUrl = ""
                            }
                        }
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Colors.accent)
                    }
                }
            }
        }
    }
    
    private func generateList() {
        withAnimation(.spring()) {
            isProcessing = true
            generatedItems = []
            generatedRecipe = nil
            showItems = false
        }
        
        // Your real network / AI call would go here
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.spring()) {
                isProcessing = false
                
                let lowerUrl = recipeUrl.lowercased()
                
                // Detection logic
                let youtubeID = extractYouTubeID(from: recipeUrl)
                let isSocialLink = lowerUrl.contains("tiktok") || lowerUrl.contains("instagram")
                
                if let id = youtubeID {
                    // It's a YouTube Video (Standard, Short, or Mobile)
                    let thumbUrl = "https://img.youtube.com/vi/\(id)/hqdefault.jpg"
                    
                    // Specific check for Paneer Butter Masala
                    if lowerUrl.contains("buounn_bmy4") || lowerUrl.contains("masala") || lowerUrl.contains("paneer") {
                        generatedItems = [
                            .init(name: "Paneer", quantity: "250g"),
                            .init(name: "Butter", quantity: "3 tbsp"),
                            .init(name: "Tomatoes", quantity: "4 large"),
                            .init(name: "Cashews", quantity: "12-15"),
                            .init(name: "Heavy Cream", quantity: "2 tbsp"),
                            .init(name: "Ginger & Garlic Paste", quantity: "1 tbsp"),
                            .init(name: "Kashmiri Red Chili Powder", quantity: "1 tsp"),
                            .init(name: "Kasuri Methi", quantity: "1 tsp"),
                            .init(name: "Garam Masala", quantity: "½ tsp")
                        ]
                        
                        generatedRecipe = Recipe(
                            title: "Authentic Paneer Butter Masala",
                            imageName: "flame.fill",
                            imageUrl: thumbUrl,
                            ingredients: generatedItems.map { "\($0.name) (\($0.quantity))" },
                            steps: [
                                "Sauté tomatoes, onions, and cashews in a little butter until soft, then blend into a silky smooth puree.",
                                "In a pan, melt the remaining butter and add ginger-garlic paste and chili powder.",
                                "Pour in the tomato-cashew puree and simmer until the fat separates.",
                                "Add the garam masala, salt, and sugar to balance the tanginess.",
                                "Gently stir in the paneer cubes and let them simmer in the gravy for 2-3 minutes.",
                                "Finish by crushing kasuri methi on top and swirling in fresh cream for that restaurant-style richness.",
                                "Serve hot with buttery garlic naan or jeera rice."
                            ]
                        )
                    } else {
                        // Generic YouTube Fallback (but with real thumbnail!)
                        generatedItems = [
                            .init(name: "Main Ingredient", quantity: "to taste"),
                            .init(name: "Spices", quantity: "as shown"),
                            .init(name: "Oil/Butter", quantity: "for cooking")
                        ]
                        
                        generatedRecipe = Recipe(
                            title: "YouTube Video Recipe",
                            imageName: "play.rectangle.fill",
                            imageUrl: thumbUrl,
                            ingredients: generatedItems.map { "\($0.name) (\($0.quantity))" },
                            steps: [
                                "Follow the steps in the video tutorial.",
                                "Prep ingredients as demonstrated.",
                                "Cook until the texture matches the video.",
                                "Serve and enjoy!"
                            ]
                        )
                    }
                } else if isSocialLink {
                    // Instagram / TikTok Logic
                    generatedItems = [
                        .init(name: "Fresh Protein", quantity: "1 lb"),
                        .init(name: "Vegetable Medley", quantity: "1 bag"),
                        .init(name: "Aromatic Herbs", quantity: "1 bunch"),
                        .init(name: "Cooking Fat", quantity: "2 tbsp")
                    ]
                    
                    generatedRecipe = Recipe(
                        title: "Extracted Social Recipe",
                        imageName: "sparkles",
                        imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop",
                        ingredients: generatedItems.map { "\($0.name) (\($0.quantity))" },
                        steps: [
                            "Prep all identified ingredients as shown in the video.",
                            "Follow the creator's specific seasoning rhythm.",
                            "Cook until golden brown and delicious.",
                            "Season once more before serving."
                        ]
                    )
                } else {
                    // Non-video links / Generic
                    generatedItems = [
                        .init(name: "Generic Flour", quantity: "1 bag"),
                        .init(name: "Eggs", quantity: "1 carton"),
                        .init(name: "Milk", quantity: "1 gallon")
                    ]
                }

                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring()) { showItems = true }
                }
            }
        }
    }
    
    private func extractYouTubeID(from url: String) -> String? {
        let pattern = #"(?<=v=)[^&#\n]+|(?<=be/)[^&#\n]+|(?<=embed/)[^&#\n]+|(?<=shorts/)[^&#\n]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        
        let range = NSRange(url.startIndex..., in: url)
        if let match = regex.firstMatch(in: url, range: range) {
            if let idRange = Range(match.range, in: url) {
                return String(url[idRange])
            }
        }
        return nil
    }
}

// ────────────────────────────────────────────────
// Modern Glass Card (reusable)
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        content()
            .background(.ultraThinMaterial)
            .background(DesignSystem.Colors.glassBackground.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(DesignSystem.Colors.glassBorder.opacity(0.6), lineWidth: 0.8)
            }
            .shadow(color: .black.opacity(0.14), radius: 20, x: 0, y: 12)
    }
}

// ────────────────────────────────────────────────
// Floating label style TextField (popular 2025–2026 pattern)
struct FloatingTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(placeholder)
                .font(.subheadline)
                .foregroundStyle(text.isEmpty && !isFocused ? .white.opacity(0.5) : DesignSystem.Colors.accent)
                .offset(y: text.isEmpty && !isFocused ? 0 : -28)
                .scaleEffect(text.isEmpty && !isFocused ? 1 : 0.85, anchor: .leading)
            
            TextField("", text: $text)
                .focused($isFocused)
                .font(.body)
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isFocused ? DesignSystem.Colors.accent : .white.opacity(0.2), lineWidth: 1.2)
                )
        }
        .animation(.easeOut(duration: 0.25), value: text.isEmpty || isFocused)
    }
}

// ────────────────────────────────────────────────
// Updated Grocery Row – cleaner, more tactile
struct GroceryRow: View {
    @State private var isChecked = false
    let item: GroceryItem
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.7)) {
                    isChecked.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(isChecked ? .green : .white.opacity(0.4), lineWidth: 2.2)
                        .frame(width: 28, height: 28)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(isChecked, pattern: .solid, color: .white.opacity(0.4))
                    .foregroundStyle(isChecked ? .white.opacity(0.45) : .white)
                
                Text(item.quantity)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.12), lineWidth: 0.8)
        }
        .scaleEffect(isChecked ? 0.97 : 1.0)
        .opacity(isChecked ? 0.75 : 1.0)
        .animation(.spring(), value: isChecked)
    }
}

// Your existing models & helpers remain mostly unchanged
struct GroceryItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: String
}

// Keep your nice loader animation
struct LottieLikeAnimation: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.accent.opacity(0.15), lineWidth: 14)
            
            Circle()
                .trim(from: 0, to: animate ? 0.75 : 0.2)
                .stroke(DesignSystem.Colors.accent, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(animate ? 360 : 0))
                .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: animate)
            
            Image(systemName: "sparkles")
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.accent)
                .scaleEffect(animate ? 1.25 : 0.9)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

#Preview {
    GroceryGeneratorView()
        .preferredColorScheme(.dark)
}
