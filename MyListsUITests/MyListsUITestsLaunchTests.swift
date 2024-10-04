//
//  ReusableListsUITestsLaunchTests.swift
//  ReusableListsUITests
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import XCTest
import SwiftData
@testable import ReusableLists

final class ReusableListsUITestsLaunchTests: XCTestCase {
    private var app: XCUIApplication!
    private var modelContainer: ModelContainer!
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    @MainActor
    override func setUpWithError() throws {
        modelContainer = TestDataController.previewContainer
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
//        modelContainer = TestDataController.previewContainer
       
         
    }

    @MainActor func testLaunch() throws {
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        var attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
        
        app.images["plus"].firstMatch.tap()
        attachment = XCTAttachment(screenshot: app.screenshot(), quality: .original)
        attachment.name = "Add List"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
