import SwiftUI

struct Symbol: Identifiable, Equatable {
    let id: Int
    let type: SymbolType
    var isReturned: Bool
}

enum SymbolType: CaseIterable {
    case starFill
    case pencil
    case trash
    case star
    case heart
    case paperplane
    case folder
    case sun
    case moon
    case flame

    var image: Image {
        switch self {
        case .starFill: return Image(systemName: "star.fill")
        case .pencil: return Image(systemName: "pencil")
        case .trash: return Image(systemName: "trash")
        case .star: return Image(systemName: "star")
        case .heart: return Image(systemName: "heart.fill")
        case .paperplane: return Image(systemName: "paperplane")
        case .folder: return Image(systemName: "folder")
        case .sun: return Image(systemName: "sun.min")
        case .moon: return Image(systemName: "moon")
        case .flame: return Image(systemName: "flame")
        }
    }
}
