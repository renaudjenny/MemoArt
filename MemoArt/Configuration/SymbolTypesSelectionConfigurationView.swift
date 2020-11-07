import SwiftUI
import ComposableArchitecture

struct SymbolTypesSelectionConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    let columns =  Array(repeating: GridItem(.flexible(minimum: 65, maximum: 120)), count: 4)

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                Text("Choose the cards you want to play with")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("The game will randomly display 10 cards among the ones you chose")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)

                Group {
                    Text("\(viewStore.selectedSymbolTypes.count)")
                        .bold()
                        .foregroundColor(
                            viewStore.selectedSymbolTypes.count > 10
                                ? .green
                                : .orange
                        )
                        + Text("/10")
                }
                .padding(.top)
                .animation(nil)

                if viewStore.selectedSymbolTypes.count <= 10 {
                    Text("Attention! You have to use 10 cards or more")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.top)
                }

                LazyVGrid(columns: columns) {
                    ForEach(SymbolType.allCases, id: \.self) { symbolType in
                        Button {
                            withAnimation {
                                viewStore.send(
                                    viewStore.selectedSymbolTypes.contains(symbolType)
                                        ? .unselectSymbolType(symbolType)
                                        : .selectSymbolType(symbolType)
                                )
                            }
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
                    .accessibility(label: Text("selected"))
            } else {
                content
                    .overlay(Color.black.opacity(2/3))
                    .overlay(Text("❌"))
                    .cornerRadius(8)
                    .accessibility(label: Text("unselected"))
            }
        }
    }
}

struct SymbolTypesSelectionConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolTypesSelectionConfigurationView(store: Store(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(mainQueue: .preview)
        ))
    }
}
