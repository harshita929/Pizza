//
//  RecipeDetailView.swift
//  Tavolo
//
//  Created by Antigravity on 08/02/26.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    var onDismiss: () -> Void
    
    @State private var activeStep = 0
    @State private var showIngredients = false
    @State private var animateContent = false
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Image & Title)
                ZStack(alignment: .bottomLeading) {
                    // Image Layer
                    if let imageUrl = recipe.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(DesignSystem.Colors.glassBackground)
                                .overlay(ProgressView().tint(.white))
                        }
                        .frame(height: 340)
                        .clipped()
                    } else {
                        Rectangle()
                            .fill(DesignSystem.Colors.accent.gradient.opacity(0.3))
                            .frame(height: 240)
                            .overlay(
                                Image(systemName: recipe.imageName)
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white.opacity(0.2))
                            )
                    }
                    
                    // Gradient Overlay for text legibility
                    LinearGradient(
                        colors: [.clear, DesignSystem.Colors.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 140)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(recipe.title)
                                .font(DesignSystem.Fonts.display(size: 36))
                                .foregroundColor(.white)
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 20)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            Spacer()
                            
                            // Share Button
                            ShareLink(item: shareableText, preview: SharePreview(recipe.title, image: Image(systemName: recipe.imageName))) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(10)
                                    .background(DesignSystem.Colors.glassBackground)
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                            .scaleEffect(animateContent ? 1 : 0)
                            .opacity(animateContent ? 1 : 0)
                            
                            Button {
                                onDismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(10)
                                    .background(DesignSystem.Colors.glassBackground)
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                            .scaleEffect(animateContent ? 1 : 0)
                            .opacity(animateContent ? 1 : 0)
                        }
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                Text("30-40 min")
                            }
                            HStack(spacing: 6) {
                                Image(systemName: "flame")
                                Text("Medium")
                            }
                        }
                        .font(DesignSystem.Fonts.body(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                        .opacity(animateContent ? 1 : 0)
                        .offset(y: animateContent ? 0 : 20)
                    }
                    .padding(24)
                }
                
                // Steps Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Actual Recipe Image Card
                        if let imageUrl = recipe.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(DesignSystem.Colors.glassBackground)
                                    .overlay(ProgressView().tint(.white))
                            }
                            .frame(height: 280)
                            .cornerRadius(32)
                            .liquidGlass(cornerRadius: 32)
                            .scaleEffect(animateContent ? 1 : 0.9)
                            .opacity(animateContent ? 1 : 0)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(DesignSystem.Colors.accent.gradient.opacity(0.2))
                                    .frame(height: 280)
                                
                                Image(systemName: recipe.imageName)
                                    .font(.system(size: 80))
                                    .foregroundColor(DesignSystem.Colors.accent)
                            }
                            .liquidGlass(cornerRadius: 32)
                            .scaleEffect(animateContent ? 1 : 0.9)
                            .opacity(animateContent ? 1 : 0)
                        }
                        
                        // Morphing Steps
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Instructions")
                                .font(DesignSystem.Fonts.display(size: 24))
                                .foregroundColor(.white)
                                .opacity(animateContent ? 1 : 0)
                            
                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                StepView(
                                    index: index + 1,
                                    instruction: step,
                                    isActive: activeStep == index
                                ) {
                                    withAnimation(DesignSystem.Animations.butterySpring) {
                                        activeStep = index
                                    }
                                }
                                .opacity(animateContent ? 1 : 0)
                                .offset(y: animateContent ? 0 : 30)
                                .scaleEffect(animateContent ? 1 : 0.95)
                                .animation(
                                    DesignSystem.Animations.butterySpring.delay(0.2 + Double(index) * 0.06),
                                    value: animateContent
                                )
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .offset(y: dragOffset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.height > 0 {
                            dragOffset = gesture.translation
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            onDismiss()
                        } else {
                            withAnimation(DesignSystem.Animations.snappySpring) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
            
            // Sticky Ingredient Drawer
            ingredientDrawer
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 100)
                .animation(DesignSystem.Animations.butterySpring.delay(0.5), value: animateContent)
        }
        .onAppear {
            withAnimation(DesignSystem.Animations.butterySpring) {
                animateContent = true
            }
        }
    }
    
    // Sharing Helper
    private var shareableText: String {
        var text = "Check out this recipe for \(recipe.title) on Tavolo!\n\n"
        
        text += "🛒 INGREDIENTS:\n"
        for ingredient in recipe.ingredients {
            text += "• \(ingredient)\n"
        }
        
        text += "\n👨‍🍳 INSTRUCTIONS:\n"
        for (index, step) in recipe.steps.enumerated() {
            text += "\(index + 1). \(step)\n"
        }
        
        return text
    }
    
    private var ingredientDrawer: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .cornerRadius(2)
                    .padding(.vertical, 12)
                
                HStack {
                    Text("Ingredients")
                        .font(DesignSystem.Fonts.display(size: 22))
                    Spacer()
                    Text("\(recipe.ingredients.count) items")
                        .font(DesignSystem.Fonts.caption())
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal)
                .padding(.bottom, 15)
                
                if showIngredients {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(DesignSystem.Colors.accent)
                                        .frame(width: 6, height: 6)
                                    Text(ingredient)
                                        .font(DesignSystem.Fonts.body(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 250)
                }
            }
            .foregroundColor(.white)
            .background(.ultraThinMaterial)
            .cornerRadius(36)
            .overlay(
                RoundedRectangle(cornerRadius: 36)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.5)
            )
            .offset(y: showIngredients ? 0 : 40)
            .onTapGesture {
                withAnimation(DesignSystem.Animations.butterySpring) {
                    showIngredients.toggle()
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct StepView: View {
    let index: Int
    let instruction: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 20) {
                Text("\(index)")
                    .font(DesignSystem.Fonts.display(size: 20))
                    .foregroundColor(isActive ? DesignSystem.Colors.accent : .white.opacity(0.3))
                    .frame(width: 30)
                
                Text(instruction)
                    .font(DesignSystem.Fonts.body(size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(isActive ? nil : 2)
                    .opacity(isActive ? 1.0 : 0.4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isActive ? DesignSystem.Colors.glassBackground : Color.clear)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isActive ? DesignSystem.Colors.glassBorder : Color.clear, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    var imageUrl: String? = nil
    let ingredients: [String]
    let steps: [String]
}

#Preview {
    RecipeDetailView(recipe: Recipe(
        title: "Creamy Chicken Pasta",
        imageName: "fork.knife",
        ingredients: ["2 Chicken Breasts", "Pasta", "Heavy Cream", "Garlic", "Parmesan"],
        steps: [
            "Boil the pasta in salted water until al dente.",
            "Sauté the diced chicken breasts with garlic in a large pan.",
            "Pour in the heavy cream and let it simmer for 5 minutes.",
            "Add parmesan cheese and stir until the sauce thickens.",
            "Toss the pasta into the sauce and serve hot."
        ]
    ), onDismiss: {})
}
