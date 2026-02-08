//
//  CookbookLibraryView.swift
//  Tavolo
//
//  Created by Antigravity on 08/02/26.
//

import SwiftUI

struct CookbookLibraryView: View {
    @State private var searchText = ""
    @Namespace private var animation
    @State private var selectedCookbook: Cookbook?
    @State private var selectedIngredients: Set<String> = []
    
    let cookbooks = [
        Cookbook(title: "Signature Dishes", author: "Chef Jatin", coverImage: "star.fill", color: DesignSystem.Colors.folderOrange, height: 320),
        Cookbook(title: "New Features", author: "Antigravity", coverImage: "paperplane.fill", color: DesignSystem.Colors.folderLightBlue, height: 260),
        Cookbook(title: "Code Prototypes", author: "Chef Jatin", coverImage: "sparkles", color: DesignSystem.Colors.folderSkyBlue, height: 260),
        Cookbook(title: "Top Design Studios", author: "Eitan", coverImage: "moon.fill", color: DesignSystem.Colors.folderOrange, height: 260),
        Cookbook(title: "Whop", author: "Creator", coverImage: "leaf.fill", color: DesignSystem.Colors.folderLavender, height: 260),
        Cookbook(title: "Vercel", author: "Next.js", coverImage: "triangle.fill", color: DesignSystem.Colors.folderPaleGreen, height: 260)
    ]
    
    let suggestedIngredients = ["Chicken", "Potatoes", "Cheese", "Garlic", "Onion"]
    
    var filteredCookbooks: [Cookbook] {
        if selectedIngredients.isEmpty {
            return cookbooks
        } else {
            return cookbooks.filter { cookbook in
                let tags = mockTags(for: cookbook)
                return !selectedIngredients.isDisjoint(with: Set(tags))
            }
        }
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Hey Dan style)
                HStack {
                    Text("Hey Dan 👋")
                        .font(DesignSystem.Fonts.display(size: 28))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack(spacing: 15) {
                        Image(systemName: "square.grid.2x2")
                            .padding(10)
                            .background(DesignSystem.Colors.glassBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Image(systemName: "plus")
                            .padding(10)
                            .background(DesignSystem.Colors.glassBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .foregroundColor(.white)
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        // Ingredient Search Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("What's in your fridge?")
                                .font(DesignSystem.Fonts.body(size: 20))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Search Bar
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white.opacity(0.5))
                                TextField("Type an ingredient (e.g., Chicken)...", text: $searchText)
                                    .foregroundColor(.white)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        if !searchText.isEmpty {
                                            withAnimation(DesignSystem.Animations.snappySpring) {
                                                _ = selectedIngredients.insert(searchText.trimmingCharacters(in: .whitespacesAndNewlines))
                                                searchText = ""
                                            }
                                        }
                                    }
                                
                                if !searchText.isEmpty {
                                    Button {
                                        searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }
                            }
                            .padding()
                            .background(DesignSystem.Colors.glassBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.5)
                            )
                            .padding(.horizontal)
                            
                            // Selected Ingredients Chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                QHStack(spacing: 12) {
                                    if selectedIngredients.isEmpty {
                                        ForEach(suggestedIngredients, id: \.self) { ingredient in
                                            IngredientChip(
                                                name: ingredient,
                                                isSelected: false
                                            ) {
                                                withAnimation(DesignSystem.Animations.snappySpring) {
                                                    _ = selectedIngredients.insert(ingredient)
                                                }
                                            }
                                        }
                                    } else {
                                        ForEach(Array(selectedIngredients).sorted(), id: \.self) { ingredient in
                                            IngredientChip(
                                                name: ingredient,
                                                isSelected: true
                                            ) {
                                                withAnimation(DesignSystem.Animations.snappySpring) {
                                                    _ = selectedIngredients.remove(ingredient)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Result Grid
                        if !selectedIngredients.isEmpty {
                            // Recipe Grid View
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                                ForEach(filteredCookbooks) { cookbook in
                                    // In a real app, we'd map this to filtered RECIPES, not just cookbooks
                                    // For now, we show the cookbook that contains the match
                                    Button {
                                        withAnimation(DesignSystem.Animations.butterySpring) {
                                            selectedCookbook = cookbook
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(cookbook.color.gradient)
                                                    .aspectRatio(1, contentMode: .fit)
                                                
                                                Image(systemName: mockRecipe(for: cookbook).imageName)
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            Text(mockRecipe(for: cookbook).title)
                                                .font(DesignSystem.Fonts.body(size: 16))
                                                .foregroundColor(.white)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            // Default Folder Staggered Grid
                            HStack(alignment: .top, spacing: 16) {
                                // Column 1
                                VStack(spacing: 16) {
                                    ForEach(Array(cookbooks.enumerated()), id: \.element.id) { index, cookbook in
                                        if index % 2 == 0 {
                                            folderCardButton(for: cookbook)
                                        }
                                    }
                                }
                                
                                // Column 2
                                VStack(spacing: 16) {
                                    ForEach(Array(cookbooks.enumerated()), id: \.element.id) { index, cookbook in
                                        if index % 2 != 0 {
                                            folderCardButton(for: cookbook)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        if filteredCookbooks.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding(.vertical)
                }
                .blur(radius: selectedCookbook != nil ? 10 : 0)
                .opacity(selectedCookbook != nil ? 0.6 : 1.0)
            }
            
            // Expanded Detail View Overlay
            if let selected = selectedCookbook {
                RecipeDetailView(recipe: mockRecipe(for: selected)) {
                    withAnimation(DesignSystem.Animations.butterySpring) {
                        selectedCookbook = nil
                    }
                }
                .matchedGeometryEffect(id: selected.id, in: animation)
                .transition(.identity)
                .zIndex(100)
            }
        }
    }
    
    @ViewBuilder
    private func folderCardButton(for cookbook: Cookbook) -> some View {
        Button {
            withAnimation(DesignSystem.Animations.butterySpring) {
                selectedCookbook = cookbook
            }
        } label: {
            FolderCard(cookbook: cookbook)
                .matchedGeometryEffect(id: cookbook.id, in: animation)
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.2))
            Text("No cookbooks match your ingredients.")
                .font(DesignSystem.Fonts.body())
                .foregroundColor(.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
    
    private func mockTags(for cookbook: Cookbook) -> [String] {
        switch cookbook.title {
        case "Signature Dishes": return ["Chicken", "Potatoes", "Cheese", "Garlic", "Onion"]
        case "New Features": return ["Pasta", "Tomato"]
        case "Code Prototypes": return ["Broccoli", "Onion"]
        case "Top Design Studios": return ["Chicken", "Pasta"]
        default: return []
        }
    }
    
    private func mockRecipe(for cookbook: Cookbook) -> Recipe {
        if cookbook.title == "Signature Dishes" {
            return Recipe(
            title: "Cheesy Chicken & Potato Casserole",
            imageName: "flame.fill",
            imageUrl: "https://images.unsplash.com/photo-1594007654729-407eedc4be65?q=80&w=1000&auto=format&fit=crop",
            ingredients: [
                "1 lb Chicken Breast, diced",
                "3 large Potatoes, diced",
                "1 cup Shredded Cheese",
                "4 cloves Garlic, minced",
                "1 Yellow Onion, chopped",
                "1/2 cup Heavy Cream",
                "Salt, Pepper & Thyme to taste"
            ],
            steps: [
                "Preheat your oven to 400°F (200°C) and grease a baking dish.",
                "Dice the chicken and potatoes into bite-sized pieces.",
                "Sauté the onions and garlic in a pan until fragrant and translucent.",
                "Combine the chicken, potatoes, onions, and garlic in the baking dish.",
                "Whisk together the heavy cream, salt, pepper, and thyme, then pour over the mixture.",
                "Top generously with shredded cheese.",
                "Bake covered with foil for 30 minutes, then uncovered for another 15 minutes until golden and bubbling."
            ]
        )
        }
        
        return Recipe(
            title: "Creme's \(cookbook.title)",
            imageName: cookbook.coverImage,
            ingredients: ["Ingredients from \(cookbook.title)", "Garlic", "Onion", "Olive Oil"],
            steps: [
                "Open your \(cookbook.title) at the marked page.",
                "Prep the fresh ingredients on a clean surface.",
                "Follow the 'buttery' animations in Tavolo.",
                "Serve and enjoy the Creator contest vibe!"
            ]
        )
    }
}

struct IngredientChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(DesignSystem.Fonts.caption(size: 14))
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.glassBackground)
                )
                .overlay(
                    Capsule()
                        .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.5)
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct FolderCard: View {
    let cookbook: Cookbook
    
    var body: some View {
        ZStack {
            // Background Layer (The white tab peeking out)
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 30, height: 70)
                .offset(x: 65) // Adjusted for sleeker size
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 4, y: 0)
            
            // Front Folder Layer
            ZStack(alignment: .topLeading) {
                FolderShape()
                    .fill(cookbook.color.gradient)
                
                VStack(alignment: .leading, spacing: 12) {
                    // Icon placeholder
                    Image(systemName: cookbook.coverImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(8)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    Text(cookbook.title)
                        .font(DesignSystem.Fonts.display(size: 16))
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
            }
            .frame(height: cookbook.height) // Dynamic height for staggered masonry look
            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
        }
    }
}

struct Cookbook: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let coverImage: String
    let color: Color
    let height: CGFloat
}

// Utility view for horizontal stacks with small spacing
struct QHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            content()
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    CookbookLibraryView()
}
