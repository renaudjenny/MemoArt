import XCTest

class Marketing: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--reset-game-backup", "--use-predicted-arts", "--reset-configuration"]
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
        // app.buttons["configuration"].tap() is not working
        // Bizarrely, I can't get the navigation buttons by their accessibility identifiers...
        // so I have to workaround with the number of this button
        // Configuration button
        app.navigationBars.buttons.element(boundBy: 1).tap()

        guard app.scrollViews["configuration"].waitForExistence(timeout: 1) else {
            XCTFail("Cannot go to configuration")
            return
        }

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testEasyDifficultyScreenshot() throws {
        // app.buttons["configuration"].tap() is not working
        // Bizarrely, I can't get the navigation buttons by their accessibility identifiers...
        // so I have to workaround with the number of this button
        // Configuration button
        app.navigationBars.buttons.element(boundBy: 1).tap()

        guard app.scrollViews["configuration"].waitForExistence(timeout: 1) else {
            XCTFail("Cannot go to configuration")
            return
        }

        // It seems this bug is the same for the segmentedControls...
        // I should be able to access with easy/normal/hard identifier and not the position!
        app.segmentedControls["difficulty_level"].buttons.element(boundBy: 0).tap()
        // Back button, not ideal as well...
        app.navigationBars.firstMatch.buttons.firstMatch.tap()

        guard app.navigationBars.staticTexts["MemoArt"].waitForExistence(timeout: 1) else {
            XCTFail("Back button didn't work, impossible to go back in the main screen")
            return
        }

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testHardDifficultyScreenshot() throws {
        // app.buttons["configuration"].tap() is not working
        // Bizarrely, I can't get the navigation buttons by their accessibility identifiers...
        // so I have to workaround with the number of this button
        // Configuration button
        app.navigationBars.buttons.element(boundBy: 1).tap()

        guard app.scrollViews["configuration"].waitForExistence(timeout: 1) else {
            XCTFail("Cannot go to configuration")
            return
        }

        // It seems this bug is the same for the segmentedControls...
        // I should be able to access with easy/normal/hard identifier and not the position!
        app.segmentedControls["difficulty_level"].buttons.element(boundBy: 2).tap()
        // Back button, not ideal as well...
        app.navigationBars.firstMatch.buttons.firstMatch.tap()

        guard app.navigationBars.staticTexts["MemoArt"].waitForExistence(timeout: 1) else {
            XCTFail("Back button didn't work, impossible to go back in the main screen")
            return
        }

        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
