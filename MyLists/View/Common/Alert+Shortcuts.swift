//
//  Alert+Shortcuts.swift
//  MyLists
//
//  Created by Otávio Zabaleta on 19/09/2024.
//

import SwiftUI

extension Alert {
    init(_ title: String, message: String, dismiss: String = "OK") {
        self.init(title: Text(title), message: Text(message), dismissButton: .cancel(Text(dismiss)))
    }
    
    static var genericErrorAlert: Alert {
        Alert(defaultErrorTitle, message: defaultErrorMessage)
    }
    
    static var defaultErrorTitle: String {
        "Whoops"
    }
    
    static var defaultErrorMessage: String {
        "Unable to perform task, try again later."
    }
}
