import SwiftUI

struct ContentView: View {
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    @State private var symbols: [(String, Bool)] = Array(repeating: ("questionmark", true), count: 20)
    @State private var discoveredSymbols: [String] = []
    @State private var isGameOver = false

    var body: some View {
        VStack {
            if isGameOver {
                Text("⭐️ Bravo! ⭐️").font(.largeTitle)
                Text("Game Over")
            }
            Text("Pairs remaining: \(10 - discoveredSymbols.count)")
            LazyVGrid(columns: columns) {
                ForEach(0..<20) {
                    Card(symbol: symbols[$0].0, returned: $symbols[$0].1, cardReturned: checkGame)
                }
            }
            if isGameOver {
                Button(action: generateSymbols) {
                    Text("Another one please!")
                }
            }
        }
        .padding()
        .onAppear(perform: generateSymbols)
    }

    private func generateSymbols() {
        discoveredSymbols = []
        isGameOver = false
        symbols = zip([
            "star.fill", "star.fill",
            "pencil", "pencil",
            "trash", "trash",
            "star", "star",
            "heart.fill", "heart.fill",
            "paperplane", "paperplane",
            "folder", "folder",
            "sun.min", "sun.min",
            "moon", "moon",
            "flame", "flame",
        ], Array(repeating: true, count: 20)).shuffled()
    }

    private func checkGame(with symbol: String) {
        let returnedSymbols = symbols
            .filter { !discoveredSymbols.contains($0.0) }
            .filter { $0.1 == false }
        guard returnedSymbols.count > 0 else { return }

        if returnedSymbols.count == 1 {
            if returnedSymbols[0].0 == symbol {
                discoveredSymbols.append(symbol)
            }
        }

        if discoveredSymbols.count >= 10 {
            isGameOver = true
        }

        guard returnedSymbols.count > 1 else { return }
        withAnimation(Animation.default.delay(0.2)) {
            symbols = symbols.map({
                if discoveredSymbols.contains($0.0) {
                    return ($0.0, false)
                }
                return ($0.0, true)
            })
        }
    }
}

struct Card: View {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
