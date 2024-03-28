import SwiftUI

class GameState: ObservableObject {
    @Published var won = false
}

@main
struct DeepBlueGame: App {
    @State var menuDismissed: Bool = false
    @StateObject var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            ZStack {
                UnderwaterView(menuDismissed: $menuDismissed)
                IntroView(menuDismissed: $menuDismissed)
                if gameState.won {
                    WinView()
                }
            }
            .environmentObject(gameState)
            .task {
                try? await Task.sleep(for: .milliseconds(1750))
                withAnimation {
                    menuDismissed = true
                }
            }
        }
    }
}
