//
//  WaitTimes.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/10/2024.
//

import Foundation

struct WaitTimes {
    
    static let dismiss: UInt64 = 500_000_000
    static let tabSelection: UInt64 = 200_000_000
    static let dismissSheetAndInsertOrRemove: UInt64 = 400_000_000
    static let dismissAndEdit: UInt64 = 200_000_000
}
