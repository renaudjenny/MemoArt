import SwiftUI

struct Card: Identifiable, Equatable, Codable {
    let id: Int
    let art: Art
    var isFaceUp: Bool
}

enum Art: String, CaseIterable, Codable {
    case artDeco
    case arty
    case cave
    case childish
    case destructured
    case geometric
    case gradient
    case impressionism
    case pixelArt
    case watercolor
    case stillLife
    case popArt
    case shadow
    case moderArt
    case chalk
    case symmetry
    case fruitArt

    var image: Image {
        switch self {
        case .artDeco: return Image("Art Deco")
        case .arty: return Image("Arty")
        case .cave: return Image("Cave")
        case .childish: return Image("Childish")
        case .destructured: return Image("Destructured")
        case .geometric: return Image("Geometric")
        case .gradient: return Image("Gradient")
        case .impressionism: return Image("Impressionism")
        case .pixelArt: return Image("Pixel Art")
        case .watercolor: return Image("Watercolor")
        case .stillLife: return Image("Nature morte")
        case .popArt: return Image("Pop Art")
        case .shadow: return Image("Shadow")
        case .moderArt: return Image("Modern Art")
        case .chalk: return Image("Chalk")
        case .symmetry: return Image("Symmetry")
        case .fruitArt: return Image("Fruit Art")
        }
    }

    var description: String {
        switch self {
        case .artDeco: return "Art Deco"
        case .arty: return "Arty"
        case .cave: return "Cave"
        case .childish: return "Childish"
        case .destructured: return "Destructured"
        case .geometric: return "Geometric"
        case .gradient: return "Gradient"
        case .impressionism: return "Impressionism"
        case .pixelArt: return "Pixel Art"
        case .watercolor: return "Watercolor"
        case .stillLife: return "Still Life"
        case .popArt: return "Pop Art"
        case .shadow: return "Shadow"
        case .moderArt: return "Modern Art"
        case .chalk: return "Chalk"
        case .symmetry: return "Symmetry"
        case .fruitArt: return "Fruit Art"
        }
    }
}

extension Array where Element == Card {
    static func newGame(from arts: Set<Art>) -> Self {
        let selectedArts = arts.shuffled().prefix(10)
        let arts = selectedArts + selectedArts
        return arts.shuffled().enumerated().map {
            Card(id: $0, art: $1, isFaceUp: false)
        }
    }

    static var newGame: Self {
        newGame(from: Set(Art.allCases))
    }

    #if DEBUG
    static var predicted: Self {
        predicted()
    }

    static func predicted(
        from arts: [Art] = Art.allCases,
        isFaceUp: Bool = false
    ) -> Self {
        let selectedArts = arts.prefix(10)
        let cards = selectedArts + selectedArts
        return cards.enumerated().map {
            Card(id: $0, art: $1, isFaceUp: isFaceUp)
        }
    }
    #endif
}
