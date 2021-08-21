#if os(macOS)
import XCTest

extension Marketing {
    func navigateToConfiguration() {
        XCUIApplication().buttons["configuration"].tap()
    }

    func selectDifficulty(levelIdentifier: String) {
        let buttonPosition: Int
        switch levelIdentifier {
        case "easy": buttonPosition = 0
        case "normal": buttonPosition = 1
        case "hard": buttonPosition = 2
        default: buttonPosition = -1
        }

        XCUIApplication().radioGroups["difficulty_level"].radioButtons.element(boundBy: buttonPosition).tap()
        XCUIApplication().buttons["done"].tap()
    }
}
#endif
