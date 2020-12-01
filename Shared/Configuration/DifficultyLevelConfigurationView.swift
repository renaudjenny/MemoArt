import SwiftUI
import ComposableArchitecture

struct DifficultyLevelConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("A new game will use \(viewStore.difficultyLevel.cardsCount) cards")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()
                Picker("Difficulty Level", selection: difficultyLevelBinding(store: viewStore)) {
                    Text("Easy").tag(DifficultyLevel.easy)
                    Text("Normal").tag(DifficultyLevel.normal)
                    Text("Hard").tag(DifficultyLevel.hard)
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green, Color.blue, Color.red]),
                        startPoint: .leading, endPoint: .trailing
                    )
                    .opacity(pickerBackgroundOpacity)
                    .cornerRadius(8)
                )
                .padding([.horizontal, .bottom])
            }
        }
    }

    private func difficultyLevelBinding(
        store: ViewStore<ConfigurationState, ConfigurationAction>
    ) -> Binding<DifficultyLevel> {
        store.binding(
            get: { $0.difficultyLevel },
            send: { .changeDifficultyLevel($0) }
        )
    }

    private var pickerBackgroundOpacity: Double {
        colorScheme == .light ? 20/100 : 80/100
    }
}
