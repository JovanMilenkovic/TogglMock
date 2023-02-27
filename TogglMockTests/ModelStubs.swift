//
//  ModelStubs.swift
//  TogglMockTests
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import Foundation
@testable import TogglMock

extension Activity {
    static func stub(
        id: UUID = UUID(),
        description: String? = nil,
        duration: TimeInterval = 0,
        date: Date = Date(timeIntervalSince1970: 0)
    ) -> Activity {
        Activity(id: id, description: description, duration: duration, date: date)
    }
}
