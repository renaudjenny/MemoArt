import XCTest

class Marketing: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--reset-game-backup", "--use-predicted-arts"]
        app.launch()
    }

    func testGameScreenshot() throws {
        app.buttons["card number 0"].tap()
        app.buttons["card number 1"].tap()
        app.buttons["card number 2"].tap()
        app.buttons["card number 3"].tap()
        app.buttons["card number 0"].tap()
        app.buttons["card number 1"].tap()
        app.buttons["card number 2"].tap()
        app.buttons["card number 3"].tap()
        app.buttons["card number 1"].tap()
        app.buttons["card number 11"].tap()
        app.buttons["card number 3"].tap()
        app.buttons["card number 13"].tap()
        app.buttons["card number 4"].tap()
        app.buttons["card number 14"].tap()
        app.buttons["card number 2"].tap()
        app.buttons["card number 5"].tap()

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testConfigurationScreenshot() throws {
        app.buttons["configuration"].tap()
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
