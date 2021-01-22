import SwiftUI
import ComposableArchitecture

struct SetupConfigurationSheetView: ViewModifier {
    let store: Store<AppState, AppAction>

    func body(content: Content) -> some View {
        WithViewStore(store) { viewStore in
            content.background(EmptyView().sheet(isPresented: isPresented(viewStore: viewStore)) {
                configurationSheet(viewStore: viewStore)
            })
        }
    }

    private func configurationSheet(viewStore: ViewStore<AppState, AppAction>) -> some View {
        VStack {
            ScrollView {
                GroupBox(label: Text("Choose a difficulty level")) {
                    DifficultyLevelConfigurationView(store: store.configurationStore)
                }
                .padding()

                GroupBox(label: Text("Choose the cards you want to play with")) {
                    ArtsSelectionConfigurationView(store: store.configurationStore)
                }
                .padding()
            }
            HStack {
                Spacer()
                Button { viewStore.send(.configuration(.hideConfiguration)) } label: {
                    Text("Done")
                }
                .padding([.bottom, .trailing])
                .accessibilityIdentifier("done")
            }
            .modifier(SetupDifficultyLevelChangedAlert(store: store))
        }
    }

    private func isPresented(viewStore: ViewStore<AppState, AppAction>) -> Binding<Bool> {
        viewStore.binding(get: { $0.configuration.isConfigurationPresented }, send: .configuration(.hideConfiguration))
    }
}
