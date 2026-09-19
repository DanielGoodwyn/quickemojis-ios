import SwiftUI
import AVFoundation

struct Page2View: View {
    let emojis = EmojiData.shared.emojis
    @State private var bgColor = Color.red
    @State private var circleColor = Color.blue
    @State private var circleSize: CGFloat = 200
    @State private var circlePosition: CGPoint = CGPoint(x: 200, y: 300)
    @State private var randomItem: EmojiItem? = nil
    private let synthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                bgColor.ignoresSafeArea()
                
                if let item = randomItem {
                    ZStack {
                        Circle()
                            .fill(circleColor)
                            .frame(width: circleSize, height: circleSize)
                            .shadow(radius: 10)
                        
                        Text(item.emoji)
                            .font(.system(size: circleSize * 0.6))
                    }
                    .position(circlePosition)
                    .onTapGesture {
                        randomize(in: geo.size)
                    }
                }
            }
            .onAppear {
                if randomItem == nil {
                    randomize(in: geo.size)
                }
            }
            .onChange(of: geo.size) { newSize in
                let maxX = max(0, newSize.width - circleSize)
                let maxY = max(0, newSize.height - circleSize)
                
                var newX = circlePosition.x
                var newY = circlePosition.y
                
                if newX - circleSize/2 > maxX { newX = maxX + circleSize/2 }
                if newX - circleSize/2 < 0 { newX = circleSize/2 }
                
                if newY - circleSize/2 > maxY { newY = maxY + circleSize/2 }
                if newY - circleSize/2 < 0 { newY = circleSize/2 }
                
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    circlePosition = CGPoint(x: newX, y: newY)
                }
            }
        }
    }
    
    private func randomize(in size: CGSize) {
        bgColor = Color(hue: .random(in: 0...1), saturation: .random(in: 0.6...0.9), brightness: .random(in: 0.7...0.9))
        circleColor = Color(hue: .random(in: 0...1), saturation: .random(in: 0.6...0.9), brightness: .random(in: 0.7...0.9))
        
        let minSize: CGFloat = 100
        let maxSize = min(size.width, size.height) * 0.8
        circleSize = CGFloat.random(in: minSize...maxSize)
        
        let maxX = max(0, size.width - circleSize)
        let maxY = max(0, size.height - circleSize)
        let x = CGFloat.random(in: 0...maxX) + circleSize/2
        let y = CGFloat.random(in: 0...maxY) + circleSize/2
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            circlePosition = CGPoint(x: x, y: y)
        }
        
        randomItem = emojis.randomElement()
        if let item = randomItem {
            let utterance = AVSpeechUtterance(string: item.name)
            synthesizer.stopSpeaking(at: .immediate)
            synthesizer.speak(utterance)
        }
    }
}
