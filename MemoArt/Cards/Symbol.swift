import SwiftUI

struct Symbol: Identifiable, Equatable {
    let id: Int
    let type: SymbolType
    var isFaceUp: Bool
}

enum SymbolType: CaseIterable {
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
    case pattern

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
        case .pattern: return Image("Pattern")
        }
    }
}

extension Array where Element == Symbol {
    static var newGameSymbols: Self {
        let selectedSymbols = SymbolType.allCases.shuffled().prefix(10)
        let symbolTypes = selectedSymbols + selectedSymbols
        return symbolTypes.shuffled().enumerated().map {
            Symbol(id: $0, type: $1, isFaceUp: false)
        }
    }

    #if DEBUG
    static var predictedGameSymbols: Self {
        predictedGameSymbols()
    }

    static func predictedGameSymbols(isCardsFaceUp: Bool = false) -> Self {
        let selectedSymbols = SymbolType.allCases.prefix(10)
        let symbolTypes = selectedSymbols + selectedSymbols
        return symbolTypes.enumerated().map {
            Symbol(id: $0, type: $1, isFaceUp: isCardsFaceUp)
        }
    }
    #endif
}
