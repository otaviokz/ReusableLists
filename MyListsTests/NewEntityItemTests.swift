//
//  NewEntityItemTestd.swift
//  ReusableListsTests
//
//  Created by okz on 22/01/25.
//

import Testing
import SwiftUI
import XCTest
@testable import ReusableLists


struct NewEntityItemTestd {
    
    func testToDoListItem() throws {
        // GIVEN
        let item = NewEntityItem.toDoList(entity: ToDoList("List"))
        
        // WHEN
        let expectedMessage = "⚠ An item named \"\(item.name)\" already exists for this List."
        
        // THEN
        XCTAssertEqual(expectedMessage, item.nameNotAvailableMessage)
    }
    
    func testBlueprintItem() throws {
        // GIVEN
        let item = NewEntityItem.blueprint(entity: Blueprint("Blueprint"))
        
        // WHEN
        let expectedMessage = "⚠ An item named \"\(item.name)\" already exists for this Blueprint."
        
        // THEN
        XCTAssertEqual(expectedMessage, item.nameNotAvailableMessage)
    }
}
