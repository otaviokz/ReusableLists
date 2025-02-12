//
//  Bindable+Shiet.swift
//  ReusableLists
//
//  Created by okz on 10/02/25.
//

import Foundation
import SwiftUI

extension Binding<Int>: @retroactive Equatable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}
