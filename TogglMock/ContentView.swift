//
//  ContentView.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import SwiftUI

class ContentViewStore: ObservableObject {
    let activitiesViewStore: ActivitiesViewStore
    let activityCreationViewStore: ActivityCreationViewStore

    init() {
        let activitiesService = UserDefaultsActivitiesService(userDefaults: .standard)

        let activitiesViewStore = ActivitiesViewStore(service: activitiesService)
        self.activitiesViewStore = activitiesViewStore

        self.activityCreationViewStore = ActivityCreationViewStore(
            tickInterval: 1,
            timerFormatter: { DateFormatter.secondsFormatter.string(from: $0) ?? ""},
            completion: { description, ticks in
                do {
                    try activitiesService.insert(description: description, duration: ticks)
                    Task { await activitiesViewStore.load() }
                } catch {
                    withAnimation { activitiesViewStore.error = error }
                }
            }
        )
    }
}

struct ContentView: View {
    @StateObject var store = ContentViewStore()

    var body: some View {
        VStack {
            activitiesView
            activityCreationView
        }
        .frame(maxHeight: .infinity)
        .padding()
    }

    var activitiesView: some View {
        ActivitiesView(store: store.activitiesViewStore)
    }

    var activityCreationView: some View {
        ActivityCreationView(store: store.activityCreationViewStore)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

