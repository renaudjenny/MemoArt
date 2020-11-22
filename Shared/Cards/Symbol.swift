import SwiftUI

struct Symbol: Identifiable, Equatable, Codable {
    let id: Int
    let type: SymbolType
    var isFaceUp: Bool
}

enum SymbolType: String, CaseIterable, Codable {
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

extension Array where Element == Symbol {
    static func newGameSymbols(from symbolTypes: Set<SymbolType>) -> Self {
        let selectedSymbols = symbolTypes.shuffled().prefix(10)
        let symbolTypes = selectedSymbols + selectedSymbols
        return symbolTypes.shuffled().enumerated().map {
            Symbol(id: $0, type: $1, isFaceUp: false)
        }
    }

    static var newGameSymbols: Self {
        newGameSymbols(from: Set(SymbolType.allCases))
    }

    #if DEBUG
    static var predictedGameSymbols: Self {
        predictedGameSymbols()
    }

    static func predictedGameSymbols(
        from symbolTypes: [SymbolType] = SymbolType.allCases,
        isCardsFaceUp: Bool = false
    ) -> Self {
        let selectedSymbols = symbolTypes.prefix(10)
        let symbolTypes = selectedSymbols + selectedSymbols
        return symbolTypes.enumerated().map {
            Symbol(id: $0, type: $1, isFaceUp: isCardsFaceUp)
        }
    }
    #endif
}
