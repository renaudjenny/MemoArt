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
        let store = TestStore(
            initialState: HighScoresState(
                scores: .test
            ),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment()
        )

        let newHighScore = HighScore(score: 10, name: "Peach", date: .test)
        let anotherNewHighScore = HighScore(score: 11, name: "Yoshi", date: .test)
        store.assert(
            .send(.addScore(newHighScore)) {
                $0.scores = [newHighScore] + [HighScore].test.prefix(9)
            },
            .send(.addScore(anotherNewHighScore)) {
                $0.scores = [newHighScore, anotherNewHighScore] + [HighScore].test.prefix(8)
            },
            .send(.addScore(HighScore(score: 200, name: "Will not be in the HighScore", date: .test))) {
                // Ensure we are not adding a score that is out of the best 10 scores
                $0.scores = [newHighScore, anotherNewHighScore] + [HighScore].test.prefix(8)
            }
        )
    }

    func testNewHighScoreWithTheSameValueAsAnotherIsAddedOnTopOfTheFirstSameScore() {
        let store = TestStore(
            initialState: HighScoresState(
                scores: .test
            ),
            reducer: highScoresReducer,
            environment: HighScoresEnvironment()
        )

        let newHighScore = HighScore(score: 20, name: "Peach", date: Date.test.advanced(by: 1))
        let anotherNewHighScore = HighScore(score: 30, name: "Yoshi", date: Date.test.advanced(by: 2))
        store.assert(
            .send(.addScore(newHighScore)) {
                $0.scores = [newHighScore] + [HighScore].test.prefix(9)
            },
            .send(.addScore(anotherNewHighScore)) {
                $0.scores = [
                    newHighScore,
                    HighScore(score: 20, name: "Test 0", date: .test),
                    anotherNewHighScore,
                    HighScore(score: 30, name: "Test 1", date: .test),
                    HighScore(score: 40, name: "Test 2", date: .test),
                    HighScore(score: 50, name: "Test 3", date: .test),
                    HighScore(score: 60, name: "Test 4", date: .test),
                    HighScore(score: 70, name: "Test 5", date: .test),
                    HighScore(score: 80, name: "Test 6", date: .test),
                    HighScore(score: 90, name: "Test 7", date: .test),
                ]
            }
        )
    }
}

extension Date {
    static let test = Date(timeIntervalSince1970: 12345)
}

extension Array where Element == HighScore {
    static var test: Self {
        (0..<10).map { HighScore(score: ($0 + 2) * 10, name: "Test \($0)", date: .test) }
    }
}
