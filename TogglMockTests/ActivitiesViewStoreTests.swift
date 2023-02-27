//
//  ActivitiesViewStoreTests.swift
//  TogglMockTests
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import XCTest
@testable import TogglMock

final class ActivitiesViewStoreTests: XCTestCase {
    func test_load_setsActivities() async {
        let service = TestActivitiesService()
        service.activitiesResponse = [.stub(), .stub()]
        let sut = makeSUT(service: service)

        await sut.load()

        XCTAssertEqual(sut.activities, service.activitiesResponse)
    }

    func test_update_callsUpdateWithNewActivity() async throws {
        let service = TestActivitiesService()
        let sut = makeSUT(service: service)
        let activity = Activity.stub()
        sut.activities = [activity]

        await sut.update(activity: activity, newDescription: "new desc")

        let update = try XCTUnwrap(service.updateCalls.last)
        XCTAssertEqual(service.updateCalls.count, 1)
        XCTAssertEqual(update.description, "new desc")
        XCTAssertEqual(update.id, activity.id)
        XCTAssertEqual(update.duration, activity.duration)
    }

    func test_update_setsError_ifFailed() async throws {
        let service = TestActivitiesService()
        let sut = makeSUT(service: service)
        let error = NSError(domain: "d", code: 123)
        service.updateError = error

        await sut.update(activity: .stub(), newDescription: "new desc")

        XCTAssertEqual(sut.error?.localizedDescription, error.localizedDescription)
    }

    func test_delete_callsDeleteAtSingleIndex() async {
        let service = TestActivitiesService()
        let sut = makeSUT(service: service)
        let activity = Activity.stub()
        sut.activities = [activity]

        await sut.delete(at: [0])

        XCTAssertEqual(service.deleteCalls, [activity])
    }

    func test_delete_callsDeleteAtMultipleIndices() async {
        let service = TestActivitiesService()
        let sut = makeSUT(service: service)
        let activity1 = Activity.stub()
        let activity2 = Activity.stub()
        sut.activities = [activity1, .stub(), activity2]

        await sut.delete(at: [0, 2])

        XCTAssertEqual(service.deleteCalls, [activity1, activity2])
    }

    func makeSUT(service: ActivitiesService = TestActivitiesService()) -> ActivitiesViewStore {
        ActivitiesViewStore(service: service)
    }
}

class TestActivitiesService: ActivitiesService {
    var activitiesResponse: [Activity] = []
    var updateError: Error?

    var updateCalls: [Activity] = []
    var deleteCalls: [Activity] = []

    func activities() async -> [Activity] {
        activitiesResponse
    }

    func update(_ activity: Activity) async throws {
        updateCalls.append(activity)
        if let error = updateError {
            throw error
        }
    }

    func delete(_ activity: Activity) async throws {
        deleteCalls.append(activity)
    }
}
