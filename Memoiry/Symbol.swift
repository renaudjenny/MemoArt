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
        }
    }
}

extension Array where Element == Symbol {
    static var newGameSymbols: Self {
        let symbolTypes = SymbolType.allCases + SymbolType.allCases
        return symbolTypes.shuffled().enumerated().map {
            Symbol(id: $0, type: $1, isFaceUp: false)
        }
    }

    #if DEBUG
    static var predictedGameSymbols: Self {
        predictedGameSymbols()
    }

    static func predictedGameSymbols(isCardsFaceUp: Bool = false) -> Self {
        let symbolTypes = SymbolType.allCases + SymbolType.allCases
        return symbolTypes.enumerated().map {
            Symbol(id: $0, type: $1, isFaceUp: isCardsFaceUp)
        }
    }
    #endif
}
