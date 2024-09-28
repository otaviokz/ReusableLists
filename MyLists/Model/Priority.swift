////
////  Priority.swift
////  MyLists
////
////  Created by Otávio Zabaleta on 20/09/2024.
////
//
//import SwiftUI
//
//enum Priority: Int {
//    case low = 0
//    case medium = 1
//    case high = 2
//    
//    init(rawValue: Int) {
//        switch rawValue {
//            case 0: self = .low
//            case 1: self = .medium
//            default: self = .high
//        }
//    }
//    
//    var color: Color {
//        switch self {
//            case .low: return .green
//            case .medium: return .yellow
//            case .high: return .red
//        }
//    }
//    
//    var coloredCircle: some View {
//        switch self {
//            case .low:
//                return Self.dot.foregroundColor(Self.low.color)
//            case .medium:
//                return Self.dot.foregroundColor(Self.medium.color)
//            case .high:
//                return Self.dot.foregroundColor(Self.high.color)
//        }
//    }
//}
//
//private extension Priority {
//    static var dot: Image {
//        Image(systemName: "circle.fill")
//    }
//}
//
