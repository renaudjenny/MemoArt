import SwiftUI

struct CardView: View {
    let symbol: String
    @Binding var returned: Bool
    let cardReturned: (String) -> Void

    var body: some View {
        if returned {
            Button(action: returnCard) {
                Color.red
                    .cornerRadius(8.0)
                    .aspectRatio(contentMode: .fit)
            }
        } else {
            Image(systemName: symbol)
                .renderingMode(.original)
                .font(.largeTitle)
                .padding()
                .aspectRatio(contentMode: .fit)
                .border(Color.red, width: 4)
                .cornerRadius(8.0)
        }
    }

    private func returnCard() {
        cardReturned(symbol)
        withAnimation {
            returned = false
        }
    }
}
