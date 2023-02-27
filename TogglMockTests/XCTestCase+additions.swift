//
//  XCTestCase+additions.swift
//  TogglMockTests
//
//  Created by Jovan Milenkovic on 27.2.23..
//

import XCTest

extension XCTestCase {
    func wait(for block: @escaping () -> Bool, timeout: TimeInterval = 0.1) {
        let blockExpectation = expectation(description: "block-based expectation")
        let timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            if block() {
                timer.invalidate()
                blockExpectation.fulfill()
            }
        }
        wait(for: [blockExpectation], timeout: timeout)
        timer.invalidate()
    }
}
