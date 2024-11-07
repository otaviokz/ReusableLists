//
//  UIDevice+CurrentDevice.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 06/11/2024.
//

import UIKit

extension UIDevice {
    static var iPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
