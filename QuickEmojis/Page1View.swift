import SwiftUI
import AVFoundation

struct Page1View: View {
    let emojis = EmojiData.shared.emojis
    @State private var showToast = false
    @State private var toastEmoji = ""
    private let synthesizer = AVSpeechSynthesizer()
    
    let columns = [
        GridItem(.fixed(64), spacing: 10),
        GridItem(.fixed(64), spacing: 10),
        GridItem(.fixed(64), spacing: 10),
        GridItem(.fixed(64), spacing: 10)
    ]
    
    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let safeBottom = geo.safeAreaInsets.bottom
            
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    let scrubGesture = DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let y = value.location.y
                            let percentage = max(0, min(1, y / geo.size.height))
                            let index = Int(percentage * CGFloat(emojis.count - 1))
                            proxy.scrollTo(index, anchor: .top)
                        }
                    
                    let gridWidth = min(geo.size.width * 0.85, 360)
                    let availableWidth = gridWidth - 20 - 30 // padding and spacing
                    let itemSize = max(40, availableWidth / 4)
                    
                    let dynamicColumns = [
                        GridItem(.fixed(itemSize), spacing: 10),
                        GridItem(.fixed(itemSize), spacing: 10),
                        GridItem(.fixed(itemSize), spacing: 10),
                        GridItem(.fixed(itemSize), spacing: 10)
                    ]
                    
                    HStack(spacing: 0) {
                        // Left scrubber
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(scrubGesture)
                        
                        // Main Grid
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: dynamicColumns, spacing: 10) {
                                ForEach(0..<emojis.count, id: \.self) { index in
                                    let item = emojis[index]
                                    Text(item.emoji)
                                        .font(.system(size: itemSize * 0.75))
                                        .frame(width: itemSize, height: itemSize)
                                        .onTapGesture {
                                            handleTap(item: item)
                                        }
                                        .id(index)
                                }
                            }
                            .padding(10)
                            .padding(.top, 20)
                        }
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.top, 80)
                        .padding(.bottom, 80)
                        .frame(width: gridWidth)
                        
                        // Right scrubber
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(scrubGesture)
                    }
                }
                
                if showToast {
                    Text(toastEmoji)
                        .font(.system(size: 100))
                        .padding(40)
                        .background(.ultraThinMaterial)
                        .cornerRadius(32)
                        .shadow(radius: 20)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(1)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func handleTap(item: EmojiItem) {
        UIPasteboard.general.string = item.emoji
        toastEmoji = item.emoji
        withAnimation { showToast = true }
        
        let utterance = AVSpeechUtterance(string: item.name)
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { showToast = false }
        }
    }
}
