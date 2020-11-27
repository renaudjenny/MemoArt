import SwiftUI

extension Color {
    static let systemBackground: Self = {
        #if os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color(UIColor.systemBackground)
        #endif
    }()

    static let systemGray5: Self = {
        #if os(macOS)
        return Color(NSColor.systemGray)
        #else
        return Color(UIColor.systemGray5)
        #endif
    }()
}
