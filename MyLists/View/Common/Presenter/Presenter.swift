//
//  Presenter.swift
//  ReusableLists
//
//  Created by okz on 28/07/26.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class Presenter {
    var sheet = false
    var alert = false
    var actionSheet = false
    var alertMessage: String = ""
    var alertTitle: String? = nil
    var confirmationDialog = false
    var confirmationDialogMessage: String = ""
    func presentSheet() {
        sheet = true
    }

    func presentAlert(title: String? = nil, message: String = "") {
        clear()
        alertTitle = title
        alertMessage = message
        alert = true
    }

    func presentActionSheet() {
        clear()
        actionSheet = true
    }

    func presentConfirmationDialog(message: String = "") {
        clear()
        confirmationDialogMessage = message
        confirmationDialog = true
    }

    func clear() {
        alertTitle = nil
        alertMessage = ""
        sheet = false
        alert = false
        actionSheet = false
        confirmationDialog = false
        confirmationDialogMessage = ""
    }
}
