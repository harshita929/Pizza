import SwiftUI

struct MorphingBlobBackground: View {
    @State private var startTimestamp = Date()
    
    // Neon palette
    let colors: [Color] = [
        Color(hex: "00FFFF"), // Cyan
        Color(hex: "FF00FF"), // Magenta
        Color(hex: "7000FF"), // Deep Purple
        Color(hex: "0070FF"), // Electric Blue
        Color(hex: "FFD700")  // Gold/Oily pop
    ]
    
    var body: some View {
        ZStack {
            // Deep base background
            Color(hex: "060712")
                .ignoresSafeArea()
            
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let time = timeline.date.timeIntervalSince(startTimestamp)
                    
                    // Add a global blur to everything drawn in the canvas for the "liquid" look
                    // Note: In a real app, you might want to layer canvases or use individual blurs
                    // for performance, but for this "punchy" effect, we'll draw overlapping
                    // blurred shapes.
                    
                    context.addFilter(.blur(radius: 40))
                    
                    // Draw multiple blobs with varying paths
                    drawBlob(in: &context, size: size, time: time, index: 0, color: colors[0], radius: 180)
                    drawBlob(in: &context, size: size, time: time, index: 1, color: colors[1], radius: 220)
                    drawBlob(in: &context, size: size, time: time, index: 2, color: colors[2], radius: 200)
                    drawBlob(in: &context, size: size, time: time, index: 3, color: colors[3], radius: 250)
                    drawBlob(in: &context, size: size, time: time, index: 4, color: colors[4], radius: 150)
                }
                .blendMode(.screen) // Creates the neon/iridescent overlap
            }
            .ignoresSafeArea()
            
            // Subtle grain overlay for "premium" feel
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .ignoresSafeArea()
        }
    }
    
    private func drawBlob(in context: inout GraphicsContext, size: CGSize, time: TimeInterval, index: Int, color: Color, radius: CGFloat) {
        // Organic motion using trig functions with different offsets
        let offset = Double(index) * Double.pi / 2.5
        let speed = 0.4 + (Double(index) * 0.1)
        
        let x = size.width / 2 + CGFloat(cos(time * speed + offset)) * (size.width * 0.3)
        let y = size.height / 2 + CGFloat(sin(time * speed * 0.8 + offset)) * (size.height * 0.3)
        
        // Scale variation
        let currentScale = 1.0 + 0.2 * sin(time * speed * 0.5 + offset)
        let rect = CGRect(x: x - radius * currentScale, y: y - radius * currentScale, width: radius * 2 * currentScale, height: radius * 2 * currentScale)
        
        // Use a radial gradient for each blob to get softer centers and punchy edges
        let gradient = Gradient(colors: [color.opacity(0.8), color.opacity(0)])
        context.fill(Path(ellipseIn: rect), with: .radialGradient(gradient, center: CGPoint(x: x, y: y), startRadius: 0, endRadius: radius * currentScale))
        
        // Add an extra "core" to some blobs for depth
        if index % 2 == 0 {
            let coreRadius = radius * 0.3
            let coreRect = CGRect(x: x - coreRadius, y: y - coreRadius, width: coreRadius * 2, height: coreRadius * 2)
            context.fill(Path(ellipseIn: coreRect), with: .color(color))
        }
    }
}

#Preview {
    MorphingBlobBackground()
}
