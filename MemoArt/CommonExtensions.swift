import SwiftUI

extension View {
    @ViewBuilder
    func hidden(_ isShown: Bool) -> some View {
        switch isShown {
        case true: self.hidden()
        case false: self
        }
    }
}
