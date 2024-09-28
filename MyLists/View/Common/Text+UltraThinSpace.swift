//
//  Text+UltraThinSpace.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 26/09/2024.
//

import SwiftUI

extension Text {
    static var ultraThinSpace: Text {
        Text(" ").font(.caption2.weight(.ultraLight))
    }
}
