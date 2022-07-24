import SwiftUI

struct AddCardStyle: ViewModifier {
    let foregroundColor: Color

    func body(content: Content) -> some View {
        content
            .cornerRadius(8)
            .aspectRatio(contentMode: .fit)
            .shadow(radius: 1, x: 1, y: 1)
    }
}

#if DEBUG
import ComposableArchitecture

struct AddCardStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello, World!")
                .bold()
                .foregroundColor(.yellow)
                .modifier(AddCardStyle(foregroundColor: .red))
                .frame(width: 150)
            Image("Pop Art")
                .resizable()
                .modifier(AddCardStyle(foregroundColor: .red))
                .frame(width: 150)
            Image("Shadow")
                .resizable()
                .modifier(AddCardStyle(foregroundColor: .black))
                .frame(width: 150)
            GameCardView(
                store: Store(initialState: .preview, reducer: gameReducer, environment: .preview),
                card: GameState.preview.cards.first ?? Card(id: 0, art: .artDeco, isFaceUp: false)
            )
            .frame(width: 150)
        }
    }
}
#endif
