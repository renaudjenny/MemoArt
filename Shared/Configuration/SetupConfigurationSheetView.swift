import SwiftUI
import ComposableArchitecture

struct SetupConfigurationSheetView: ViewModifier {
    struct ViewState: Equatable {
        var isPresented: Bool
    }
    enum ViewAction {
        case hide
    }

    let store: Store<AppState, AppAction>

    func body(content: Content) -> some View {
        WithViewStore(store.scope(
            state: { $0.configurationSheetViewState },
            action: AppAction.configurationSheetViewAction
        )) { viewStore in
            content.background(EmptyView().sheet(
                isPresented: viewStore.binding(get: { $0.isPresented }, send: .hide)
            ) {
                sheet(viewStore: viewStore)
            })
        }
    }

    private func sheet(viewStore: ViewStore<ViewState, ViewAction>) -> some View {
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
                Button { viewStore.send(.hide) } label: {
                    Text("Done")
                }
                .padding([.bottom, .trailing])
                .accessibilityIdentifier("done")
            }
            .modifier(SetupDifficultyLevelChangedAlert(store: store))
        }
    }
}

extension AppState {
    var configurationSheetViewState: SetupConfigurationSheetView.ViewState {
        .init(isPresented: configuration.isPresented)
    }
}

extension AppAction {
    static func configurationSheetViewAction(viewAction: SetupConfigurationSheetView.ViewAction) -> Self {
        switch viewAction {
        case .hide: return .configuration(.hide)
        }
    }
}
