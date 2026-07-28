//
//  Alert+Shortcuts.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 19/09/2024.
//

import SwiftUI

extension Alert {
    init(title: String = Self.genericErrorTitle, message: String = Self.genericErrorMessage, dismiss: String = "OK") {
        self.init(
            title: Text(title),
            message: Text(message),
            dismissButton: .cancel(Text(dismiss))
        )
    }
    
    static var genericErrorTitle: String { "Whoops" }
    
    static var genericErrorMessage: String { "Unable to perform task, try again later." }
}
