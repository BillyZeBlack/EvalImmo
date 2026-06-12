//
//  EvalImmoUITests.swift
//  EvalImmoUITests
//
//  Created by williams saadi on 22/03/2021.
//

import XCTest

class EvalImmoUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.exists)
    }
}
