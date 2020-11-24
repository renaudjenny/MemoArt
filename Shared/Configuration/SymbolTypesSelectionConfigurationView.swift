import SwiftUI
import ComposableArchitecture

struct SymbolTypesSelectionConfigurationView: View {
    let store: Store<ConfigurationState, ConfigurationAction>
    let columns =  Array(repeating: GridItem(.flexible(minimum: 65, maximum: 120)), count: 4)

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("A new game will randomly display 10 cards among the ones you chose")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding()

                VStack {
                    Text("\(viewStore.selectedArts.count)")
                        .bold()
                        .foregroundColor(
                            viewStore.selectedArts.count > 10
                                ? .green
                                : .orange
                        )
                        + Text("/10")
                }
                .animation(nil)

                VStack {
                    if viewStore.selectedArts.count <= 10 {
                        Text("Attention! You have to use 10 cards or more to play.")
                            .font(.callout)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(.orange)
                            )
                            .padding([.horizontal, .top])
                    }
                }
                .animation(.spring())

                LazyVGrid(columns: columns) {
                    ForEach(Art.allCases, id: \.self) { art in
                        Button {
                            viewStore.send(
                                viewStore.selectedArts.contains(art)
                                    ? .unselectArt(art)
                                    : .selectArt(art)
                            )
                        } label: {
                            art.image
                                .resizable()
                                .modifier(AddCardStyle(foregroundColor: .black))
                                .modifier(SelectionCardStyle(
                                    isSelected: viewStore.selectedArts.contains(art)
                                ))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .animation(.spring())
            }
        }
    }
}

private struct SelectionCardStyle: ViewModifier {
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
            initialState: ConfigurationState(selectedArts: .countLimit),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: .preview,
                save: { _ in },
                load: { ConfigurationState() }
            )
        ))
    }
}

extension Set where Element == Art {
    static var countLimit: Self {
        Set(Art.allCases.prefix(10))
    }
}
#endif
