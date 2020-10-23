import XCTest
@testable import MemoArt
import ComposableArchitecture

class HighScoresCoreTests: XCTestCase {
    func testAddNewScoreWhenHighScoresIsEmpty() {
        let store = TestStore(
            initialState: HighScoresState(),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment()
        )
        let newHighScore = HighScore(score: 100, name: "Mario", date: .test)
        store.assert(
            .send(.addScore(newHighScore)) {
                $0.scores = [newHighScore]
            }
        )
    }

    func testAddNewScoreWhenHighScoresIsNotEmpty() {
        let store = TestStore(
            initialState: HighScoresState(
                scores: [HighScore(score: 100, name: "Mario", date: .test)]
            ),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment()
        )
        let newHighScore = HighScore(score: 90, name: "Luigi", date: .test)
        store.assert(
            .send(.addScore(newHighScore)) {
                $0.scores = [
                    newHighScore,
                    HighScore(score: 100, name: "Mario", date: .test)
                ]
            }
        )
    }

    func testAddNewScoreButScoreIsNotTheBest() {
        let store = TestStore(
            initialState: HighScoresState(
                scores: [
                    HighScore(score: 90, name: "Luigi", date: .test),
                    HighScore(score: 100, name: "Mario", date: .test),
                ]
            ),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment()
        )
        let newHighScore = HighScore(score: 95, name: "Peach", date: .test)
        let anotherNewHighScore = HighScore(score: 105, name: "Yoshi", date: .test)
        let aThirdNewHighScore = HighScore(score: 98, name: "Toad", date: .test)
        let aFourthNewHighScore = HighScore(score: 87, name: "Wario", date: .test)
        store.assert(
            .send(.addScore(newHighScore)) {
                $0.scores = [
                    HighScore(score: 90, name: "Luigi", date: .test),
                    newHighScore,
                    HighScore(score: 100, name: "Mario", date: .test),
                ]
            },
            .send(.addScore(anotherNewHighScore)) {
                $0.scores = [
                    HighScore(score: 90, name: "Luigi", date: .test),
                    newHighScore,
                    HighScore(score: 100, name: "Mario", date: .test),
                    anotherNewHighScore,
                ]
            },
            .send(.addScore(aThirdNewHighScore)) {
                $0.scores = [
                    HighScore(score: 90, name: "Luigi", date: .test),
                    newHighScore,
                    aThirdNewHighScore,
                    HighScore(score: 100, name: "Mario", date: .test),
                    anotherNewHighScore,
                ]
            },
            .send(.addScore(aFourthNewHighScore)) {
                $0.scores = [
                    aFourthNewHighScore,
                    HighScore(score: 90, name: "Luigi", date: .test),
                    newHighScore,
                    aThirdNewHighScore,
                    HighScore(score: 100, name: "Mario", date: .test),
                    anotherNewHighScore,
                ]
            }
        )
    }

    func testAddNewScoreWhenThereIsAlready10Scores() {

    }
}

extension Date {
    static let test = Date(timeIntervalSince1970: 12345)
}
