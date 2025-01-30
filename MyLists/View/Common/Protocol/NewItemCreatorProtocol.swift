//
//  NewItemCreatorProtocol.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 20/11/2024.
//

import Foundation

public protocol NewItemCreatorProtocol {
    func isUniqueNameInEntity(name: String) -> Bool
    func createAndInsertNewItems(_ newItems: [(name: String, priority: Bool)]) throws
}
