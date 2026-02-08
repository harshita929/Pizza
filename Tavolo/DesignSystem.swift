//
//  DesignSystem.swift
//  Tavolo
//
//  Created by Antigravity on 08/02/26.
//

import SwiftUI

enum DesignSystem {
    
    // MARK: - Colors
    enum Colors {
        static let background = Color(hex: "0F172A") // Deep Slate
        static let surface = Color.white.opacity(0.1)
        static let accent = Color(hex: "F97316") // Burnt Orange / Eitan's vibe
        static let secondaryAccent = Color(hex: "8B5CF6") // Purple
        
        static let glassBackground = Color.white.opacity(0.15)
        static let glassBorder = Color.white.opacity(0.2)
        
        static let folderGreen = Color(hex: "A3FE4A")
        static let folderLightBlue = Color(hex: "D7F4FE")
        static let folderSkyBlue = Color(hex: "56C1FE")
        static let folderOrange = Color(hex: "FFAC4B")
        static let folderLavender = Color(hex: "C6C5D4")
        static let folderPaleGreen = Color(hex: "C6EBC9")
    }
    
    // MARK: - Fonts
    enum Fonts {
        // High-end Serif for titles/personality (Creme style)
        static func display(size: CGFloat = 34) -> Font {
            .serif(size: size, weight: .bold)
        }
        
        // Clean Sans-Serif for functional elements
        static func body(size: CGFloat = 17) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
        
        static func caption(size: CGFloat = 12) -> Font {
            .system(size: size, weight: .regular, design: .rounded)
        }
    }
    
    // MARK: - Animations
    enum Animations {
        // Snappy & Modern (2026 Trend)
        static let butterySpring = Animation.spring(
            response: 0.62,
            dampingFraction: 0.78,
            blendDuration: 0.1
        )
        
        static let snappySpring = Animation.spring(
            response: 0.58,
            dampingFraction: 0.82
        )
        
        static let lazySpring = Animation.spring(
            response: 0.72,
            dampingFraction: 0.75
        )
    }
}

extension Font {
    static func serif(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // Using System Serif (New York) for that premium feel
        .system(size: size, weight: weight, design: .serif)
    }
}

// MARK: - Liquid Glass View Modifiers
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DesignSystem.Colors.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
    
    func premiumShadow() -> some View {
        self.shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Shapes
struct FolderShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 20
        let notchSize: CGFloat = 60
        let notchDepth: CGFloat = 12
        
        // Start from top-left
        path.move(to: CGPoint(x: 0, y: radius))
        path.addArc(center: CGPoint(x: radius, y: radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius), radius: radius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        
        // Right edge with cutout (notch)
        let notchStart = (rect.height - notchSize) / 2
        path.addLine(to: CGPoint(x: rect.width, y: notchStart))
        
        // The Notch (Inward curve)
        path.addCurve(
            to: CGPoint(x: rect.width, y: notchStart + notchSize),
            control1: CGPoint(x: rect.width - notchDepth, y: notchStart),
            control2: CGPoint(x: rect.width - notchDepth, y: notchStart + notchSize)
        )
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius == 0 ? radius : rect.height - radius), radius: radius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: radius, y: rect.height))
        path.addArc(center: CGPoint(x: radius, y: rect.height - radius), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        path.closeSubpath()
        return path
    }
}
