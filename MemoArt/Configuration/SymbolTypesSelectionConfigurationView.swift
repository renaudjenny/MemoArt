import SwiftUI
import ComposableArchitecture

struct SymbolTypesSelectionConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    let columns =  [GridItem(.adaptive(minimum: 50, maximum: 100))]

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(SymbolType.allCases, id: \.self) { symbolType in
                        Button {
                            viewStore.send(
                                viewStore.selectedSymbolTypes.contains(symbolType)
                                    ? .unselectSymbolType(symbolType)
                                    : .selectSymbolType(symbolType)
                            )
                        } label: {
                            symbolType.image
                                .resizable()
                                .modifier(AddCardStyle(foregroundColor: .black))
                                .modifier(SelectionCardStyle(
                                    store: store,
                                    symbolType: symbolType
                                ))
                        }
                    }
                }
                .padding()
            }
        }
    }
}

private struct SelectionCardStyle: ViewModifier {
    let store: Store<ConfigurationState, ConfigurationAction>
    let symbolType: SymbolType

    func body(content: Content) -> some View {
        WithViewStore(store) { viewStore in
            if viewStore.selectedSymbolTypes.contains(symbolType) {
                content
            } else {
                content
                    .overlay(Color.black.opacity(2/3))
                    .cornerRadius(8)
            }
        }
    }
}

struct SymbolTypesSelectionConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolTypesSelectionConfigurationView(store: Store(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment()
        ))
    }
}
