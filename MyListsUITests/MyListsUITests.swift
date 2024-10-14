//
//  ReusableListsUITests.swift
//  ReusableListsUITests
//
//  Created by Otávio Zabaleta on 01/01/2024.
//

import XCTest

final class ReusableListsUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testCreateList() {
        // Given
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Empty lists"
        attachment.lifetime = .keepAlways
        add(attachment)
        
//        let groceriesEmptyButton = app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Groceries, Empty"]/*[[".cells.buttons[\"Groceries, Empty\"]",".buttons[\"Groceries, Empty\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        groceriesEmptyButton.swipeLeft()
//        app.navigationBars["Groceries"].buttons["Lists"].tap()
//        groceriesEmptyButton.swipeLeft()
//        
//        let app = XCUIApplication()
//        app.navigationBars["Lists"]/*@START_MENU_TOKEN@*/.images["Add"]/*[[".otherElements[\"Add\"].images[\"Add\"]",".images[\"Add\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.collectionViews/*@START_MENU_TOKEN@*/.textFields["New name"]/*[[".cells.textFields[\"New name\"]",".textFields[\"New name\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        
//        let gKey = app/*@START_MENU_TOKEN@*/.keys["G"]/*[[".keyboards.keys[\"G\"]",".keys[\"G\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        gKey.tap()
//        gKey.tap()
//        
//        let rKey = app/*@START_MENU_TOKEN@*/.keys["r"]/*[[".keyboards.keys[\"r\"]",".keys[\"r\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        rKey.tap()
//        rKey.tap()
//        
//        let oKey = app/*@START_MENU_TOKEN@*/.keys["o"]/*[[".keyboards.keys[\"o\"]",".keys[\"o\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        oKey.tap()
//        oKey.tap()
//        
//        let cKey = app/*@START_MENU_TOKEN@*/.keys["c"]/*[[".keyboards.keys[\"c\"]",".keys[\"c\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        cKey.tap()
//        cKey.tap()
//        
//        let eKey = app/*@START_MENU_TOKEN@*/.keys["e"]/*[[".keyboards.keys[\"e\"]",".keys[\"e\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        eKey.tap()
//        eKey.tap()
//
//        let plus = app.toolbarButtons["plus"].firstMatch
//        plus.waitForExistence(timeout: 2)
//        plus.tap()
        //(plus.exists, timeout: 4)
    }
    
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
