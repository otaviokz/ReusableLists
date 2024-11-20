//
//  Binding+Characterlimit.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if limit == 0 { return self }
        if self.wrappedValue.count > limit {
            Task {
                try? await Task.sleep(nanoseconds: 500)
                wrappedValue = String(wrappedValue.prefix(limit))
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                self.wrappedValue = String(self.wrappedValue.prefix(limit))
//            }
        }
        return self
    }
}
