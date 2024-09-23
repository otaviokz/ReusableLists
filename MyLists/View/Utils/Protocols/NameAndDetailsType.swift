//
//  ItemListable.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/09/2024.
//

import SwiftUI

protocol Nameable: Identifiable {
    associatedtype Nameable
    var name: String { get set }
    static var nameSizeLimit: Int { get }
}

extension Nameable {
    static var nameSizeLimit: Int { 64 }
}

protocol NameAndDetailsType: Nameable {
    var details: String { get set }
    static var detailsSizeLimit: Int { get }
}

extension NameAndDetailsType {
    static var detailsSizeLimit: Int { 128 }
}
