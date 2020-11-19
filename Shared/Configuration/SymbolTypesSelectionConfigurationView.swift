import SwiftUI
import ComposableArchitecture

struct SymbolTypesSelectionConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    let columns =  Array(repeating: GridItem(.flexible(minimum: 65, maximum: 120)), count: 4)

    var body: some View {
        ScrollView {
            WithViewStore(store) { viewStore in
                Text("Choose the cards you want to play with")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("A new game will randomly display 10 cards among the ones you chose")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack {
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

                VStack {
                    if viewStore.selectedSymbolTypes.count <= 10 {
                        Text("Attention! You have to use 10 cards or more to play.")
                            .font(.callout)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.orange)
                            )
                            .padding(.horizontal)
                    }
                }
                .animation(.spring())

                LazyVGrid(columns: columns) {
                    ForEach(SymbolType.allCases, id: \.self) { symbolType in
                        symbolType.image
                            .resizable()
                            .modifier(AddCardStyle(foregroundColor: .black))
                            .modifier(SelectionCardStyle(
                                symbolType: symbolType,
                                isSelected: viewStore.selectedSymbolTypes.contains(symbolType)
                            ))
                            .onTapGesture { viewStore.send(
                                viewStore.selectedSymbolTypes.contains(symbolType)
                                    ? .unselectSymbolType(symbolType)
                                    : .selectSymbolType(symbolType)
                            )}
                    }
                }
                .padding()
                .animation(.spring())
            }
        }
    }
}

private struct SelectionCardStyle: ViewModifier {
    let symbolType: SymbolType
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .overlay(isSelected ? Color.clear : Color.black.opacity(2/3))
            .overlay(isSelected ? nil : Text("❌"))
            .cornerRadius(8)
            .accessibility(label: isSelected ? Text("selected") : Text("unselected"))
    }
}

#if DEBUG
struct SymbolTypesSelectionConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolTypesSelectionConfigurationView(store: Store(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: .preview,
                save: { _ in },
                load: { ConfigurationState() }
            )
        ))
    }
}

struct SymbolTypesSelectionConfigurationView2_Previews: PreviewProvider {
    static var previews: some View {
        SymbolTypesSelectionConfigurationView(store: Store(
            initialState: ConfigurationState(selectedSymbolTypes: .countLimit),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: .preview,
                save: { _ in },
                load: { ConfigurationState() }
            )
        ))
    }
}

extension Set where Element == SymbolType {
    static var countLimit: Self {
        Set(SymbolType.allCases.prefix(10))
    }
}
#endif
