//
//  Alert+Shortcuts.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 19/09/2024.
//

import SwiftUI

extension Alert {
    init(_ title: String, message: String, dismiss: String = "OK") {
        self.init(
            title: Text(title),
            message: Text(message),
            dismissButton: .cancel(Text(dismiss))
        )
    }
    
    static var genericError: Alert { Alert(genericErrorTitle, message: gnericErrorMessage) }
    
    static var genericErrorTitle: String { "Whoops" }
    
    static var gnericErrorMessage: String { "Unable to perform task, try again later." }
}
