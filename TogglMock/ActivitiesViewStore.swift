//
//  ActivitiesViewStore.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import SwiftUI

protocol ActivitiesService {
    func activities() async -> [Activity]
    func update(_ activity: Activity) async throws
    func delete(_ activity: Activity) async throws
}

class ActivitiesViewStore: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var error: Error?

    private let service: ActivitiesService

    init(service: ActivitiesService) {
        self.service = service
    }

    @MainActor
    func load() async {
        let newActivities = await service.activities()
        withAnimation { self.activities = newActivities }
    }

    @MainActor
    func update(activity: Activity, newDescription: String) async {
        do {
            try await self.service.update(
                Activity(
                    id: activity.id,
                    description: newDescription,
                    duration: activity.duration,
                    date: activity.date
                )
            )
        } catch {
            withAnimation { self.error = error }
        }
    }

    @MainActor
    func delete(at indexes: IndexSet) async {
        do {
            let activitiesToRemove = indexes.map { activities[$0] }
            activities.remove(atOffsets: indexes)
            for activity in activitiesToRemove {
                try await self.service.delete(activity)
            }
        } catch {
            withAnimation { self.error = error }
        }
    }
}
