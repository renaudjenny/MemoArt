import XCTest
@testable import Memoiry
import ComposableArchitecture

class HighScoresCoreTests: XCTestCase {
    let store = TestStore(
        initialState: HighScoresState(),
        reducer: highScoresReducer,
        environment: HighScoresEnvironment()
    )

    func testAddNewScoreWhenHighScoresIsEmpty() {
        let newHighScore = HighScore(score: 100, name: "Mario", date: .test)
        store.assert(
            .send(.addScore(newHighScore)) {
                $0.scores = [newHighScore]
            }
        )
    }

    func testAddNewScoreWhenHighScoresIsNotEmpty() {
        let oldHighScore = HighScore(score: 100, name: "Mario", date: .test)
        let newHighScore = HighScore(score: 90, name: "Luigi", date: .test)
        store.assert(
            .send(.addScore(oldHighScore)) {
                $0.scores = [oldHighScore]
            },
            .send(.addScore(newHighScore)) {
                $0.scores = [newHighScore, oldHighScore]
            }
        )
    }

    func testAddNewScoreButScoreIsNotTheBest() {
        
    }

    func testAddNewScoreWhenThereIsAlready10Scores() {

    }
}

extension Date {
    static let test = Date(timeIntervalSince1970: 12345)
}
