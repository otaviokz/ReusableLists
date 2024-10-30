//
//  Logger.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/10/2024.
//

import OSLog
import SwiftUI

extension Logger {
    static let shared = Logger()
}

extension View {
    var logger: Logger { Logger.shared }
}
