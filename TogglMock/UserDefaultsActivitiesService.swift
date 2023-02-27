//
//  UserDefaultsActivitiesService.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import Foundation

// No unit tests because it's just a stand-in service
class UserDefaultsActivitiesService: ActivitiesService {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func activities() async -> [Activity] {
        activityDTOs()
            .map { Activity(id: $0.id, description: $0.description, duration: $0.duration, date: $0.date) }
    }

    func update(_ activity: Activity) async throws {
        var activities = activityDTOs()

        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }

        activities[index] = ActivityDTO(id: activity.id, description: activity.description, duration: activity.duration, date: activity.date)

        let data = try JSONEncoder().encode(activities)
        userDefaults.set(data, forKey: "activities")
    }

    func insert(description: String, duration: TimeInterval) throws {
        var activities = activityDTOs()
        let newActivity = ActivityDTO(
            id: UUID(),
            description: description.isEmpty ? nil : description,
            duration: duration,
            date: Date()
        )

        activities.insert(newActivity, at: 0)

        let data = try JSONEncoder().encode(activities)
        userDefaults.set(data, forKey: "activities")
    }

    func delete(_ activity: Activity) async throws {
        var activities = activityDTOs()

        guard let index = activities.firstIndex(where: { $0.id == activity.id }) else { return }

        activities.remove(at: index)

        let data = try JSONEncoder().encode(activities)
        userDefaults.set(data, forKey: "activities")
    }

    private func activityDTOs() -> [ActivityDTO] {
        let data = userDefaults.data(forKey: "activities") ?? Data()
        let decoder = JSONDecoder()
        return (try? decoder.decode([ActivityDTO].self, from: data)) ?? []
    }
}

private struct ActivityDTO: Codable {
    let id: UUID
    let description: String?
    let duration: TimeInterval
    let date: Date
}
