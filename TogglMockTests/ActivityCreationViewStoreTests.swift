//
//  ActivityCreationViewStoreTests.swift
//  TogglMockTests
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import XCTest
@testable import TogglMock
import Combine

final class ActivityCreationViewStoreTests: XCTestCase {
    var cancellable: AnyCancellable?

    override func tearDown() {
        cancellable = nil

        super.tearDown()
    }

    func test_toggleTimer_setsTimeFromTimerFormatter_ifNotStarted() {
        var timeValues: [String?] = []
        let sut = makeSUT(timerFormatter: { "\(Int($0))" })
        cancellable = sut.$time.dropFirst().sink { timeValues.append($0) }

        sut.toggleTimer()

        wait(for: { timeValues.starts(with: ["0", "1", "2", "3"]) })
    }

    func test_toggleTimer_resetsForMultipleUses() {
        var timeValues: [String?] = []
        let sut = makeSUT(timerFormatter: { "\(Int($0))" })
        cancellable = sut.$time.dropFirst().sink { timeValues.append($0) }

        sut.toggleTimer()
        wait(for: { timeValues.starts(with: ["0", "1", "2", "3"]) })

        sut.toggleTimer()

        sut.toggleTimer()
        wait(for: { timeValues.starts(with: ["0", "1", "2", "3"]) })
    }

    func test_toggleTimer_setsTimeAndDescriptionToNil_ifAlreadyStarted() {
        var timeValues: [String?] = []
        let sut = makeSUT(timerFormatter: { _ in "" })
        cancellable = sut.$time.dropFirst().sink { timeValues.append($0) }
        sut.toggleTimer()

        sut.toggleTimer()

        wait(for: { timeValues.reversed().starts(with: [nil]) && sut.description == "" })
    }

    func test_toggleTimer_callsCompletion_ifAlreadyStarted() {
        var completionDescription: String?

        let sut = makeSUT(completion: { description, _ in
            completionDescription = description
        })
        sut.description = "new activity"
        sut.toggleTimer()

        sut.toggleTimer()

        XCTAssertEqual(completionDescription, "new activity")
    }

    func makeSUT(
        tickInterval: Double = 0.01,
        timerFormatter: @escaping (TimeInterval) -> String = { _ in "" },
        completion: @escaping (String, TimeInterval) -> Void = { _, _ in }
    ) -> ActivityCreationViewStore {
        ActivityCreationViewStore(
            tickInterval: tickInterval,
            timerFormatter: timerFormatter,
            completion: completion
        )
    }
}
