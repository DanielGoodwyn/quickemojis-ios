import Foundation

struct EmojiItem: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
}

class EmojiData {
    static let shared = EmojiData()
    var emojis: [EmojiItem] = []
    
    init() {
        loadEmojis()
    }
    
    private func loadEmojis() {
        guard let url = Bundle.main.url(forResource: "emojis", withExtension: "json") else {
            print("Failed to locate emojis.json in bundle.")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            
            var loaded: [EmojiItem] = []
            for dict in jsonArray {
                if let emoji = dict["emoji"] as? String,
                   let name = dict["name"] as? String {
                    loaded.append(EmojiItem(emoji: emoji, name: name))
                }
            }
            self.emojis = loaded
        } catch {
            print("Failed to decode emojis.json: \(error)")
        }
    }
}
