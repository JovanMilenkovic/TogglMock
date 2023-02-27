//
//  ActivityCreationViewStore.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import SwiftUI
import Combine

class ActivityCreationViewStore: ObservableObject {
    @Published var description: String = ""
    @Published var time: String?

    private let timerFormatter: (_ tick: TimeInterval) -> String
    private let tickInterval: Double
    private let completion: (String, TimeInterval) -> Void
    private var timerCancellable: AnyCancellable?
    private var startTime: Date?

    init(
        tickInterval: Double,
        timerFormatter: @escaping (TimeInterval) -> String,
        completion: @escaping (String, TimeInterval) -> Void
    ) {
        self.tickInterval = tickInterval
        self.timerFormatter = timerFormatter
        self.completion = completion
    }

    func toggleTimer() {
        if let startTime {
            timerCancellable = nil
            self.startTime = nil
            completion(description, startTime.distance(to: Date()))
            withAnimation {
                time = nil
                description = ""
            }
        } else {
            withAnimation { self.time = self.timerFormatter(0) }
            startTime = Date()
            timerCancellable = Timer.publish(every: tickInterval, on: .main, in: .common)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .map { _ in
                    (self.startTime ?? Date()).distance(to: Date()) / self.tickInterval
                }
                .map(timerFormatter)
                .sink { time in withAnimation { self.time = time } }
        }
    }
}
