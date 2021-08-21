import XCTest

class Marketing: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = [
            "--reset-game-backup",
            "--use-predicted-arts",
            "--reset-configuration",
        ]
        app.launch()

        if XCUIApplication().buttons[XCUIIdentifierFullScreenWindow].exists {
            XCUIApplication().buttons[XCUIIdentifierFullScreenWindow].tap()
        }
    }

    func testGameScreenshot() throws {
        XCUIApplication().buttons["card number 0"].tap()
        XCUIApplication().buttons["card number 1"].tap()
        XCUIApplication().buttons["card number 2"].tap()
        XCUIApplication().buttons["card number 3"].tap()
        XCUIApplication().buttons["card number 0"].tap()
        XCUIApplication().buttons["card number 1"].tap()
        XCUIApplication().buttons["card number 2"].tap()
        XCUIApplication().buttons["card number 3"].tap()
        XCUIApplication().buttons["card number 1"].tap()
        XCUIApplication().buttons["card number 11"].tap()
        XCUIApplication().buttons["card number 3"].tap()
        XCUIApplication().buttons["card number 13"].tap()
        XCUIApplication().buttons["card number 4"].tap()
        XCUIApplication().buttons["card number 14"].tap()
        XCUIApplication().buttons["card number 2"].tap()
        XCUIApplication().buttons["card number 5"].tap()

        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testConfigurationScreenshot() throws {
        navigateToConfiguration()

        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testEasyDifficultyScreenshot() throws {
        navigateToConfiguration()

        selectDifficulty(levelIdentifier: "easy")

        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testHardDifficultyScreenshot() throws {
        navigateToConfiguration()
        selectDifficulty(levelIdentifier: "hard")

        let screenshot = XCUIApplication().screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
