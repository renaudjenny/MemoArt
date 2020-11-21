import SwiftUI
import ComposableArchitecture
import RenaudJennyAboutView

@main
struct MemoArtApp: App {
    let store = Store(
        initialState: AppState(
            game: GameState(symbols: .newGameSymbols(from: loadConfiguration().selectedSymbolTypes)),
            configuration: loadConfiguration()
        ),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            loadHighScores: loadHighScores,
            saveHighScores: saveHighScores,
            generateRandomSymbols: { .newGameSymbols(from: $0) },
            saveConfiguration: saveConfiguration,
            loadConfiguration: loadConfiguration
        )
    )
    @State private var isAboutWindowOpened = false

    var body: some Scene {
        WindowGroup {
            MainView(store: store)
                .background(EmptyView().sheet(isPresented: $isAboutWindowOpened) {
                    VStack {
                        AboutView(
                            appId: "id1536330844",
                            logo: {
                                Image("Pixel Art")
                                    .resizable()
                                    .modifier(AddCardStyle())
                                    .frame(width: 120, height: 120)
                            }
                        )
                        .buttonStyle(aboutBoutonStyle)
                        Button {
                            isAboutWindowOpened = false
                        } label: {
                            Text("Done")
                        }
                        .padding()
                    }
                })
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.pasteboard) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.undoRedo) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button {
                    isAboutWindowOpened = true
                } label: {
                    Text("About MemoArt")
                }
            }
        }
    }

    private var aboutBoutonStyle: some PrimitiveButtonStyle {
        #if os(macOS)
        return LinkButtonStyle()
        #else
        return DefaultButtonStyle()
        #endif
    }
}

// MARK: High Scores Persistence
extension MemoArtApp {
    private static let highScoresKey = "MemoArtHighScores"

    private static func loadHighScores() -> [HighScore] {
        guard
            let data = UserDefaults.standard.data(forKey: highScoresKey),
            let highScores = try? JSONDecoder().decode([HighScore].self, from: data)
        else { return [] }

        return highScores
    }

    private static func saveHighScores(highScores: [HighScore]) {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(highScores), forKey: highScoresKey)
    }
}

// MARK: Configuration Persistence
extension MemoArtApp {
    private static let configurationKey = "MemoArtConfigurationState"

    private static func saveConfiguration(configuration: ConfigurationState) {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(configuration), forKey: configurationKey)
    }

    private static func loadConfiguration() -> ConfigurationState {
        guard
            let data = UserDefaults.standard.data(forKey: configurationKey),
            let configuration = try? JSONDecoder().decode(ConfigurationState.self, from: data)
        else { return ConfigurationState() }

        return configuration
    }
}
