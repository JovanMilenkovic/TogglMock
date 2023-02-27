//
//  Activity.swift
//  TogglMock
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import Foundation

struct Activity: Identifiable, Equatable {
    let id: UUID
    let description: String?
    let duration: TimeInterval
    let date: Date
}
