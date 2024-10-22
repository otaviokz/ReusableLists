//
//  View+Screenshot.swift
//  ReusableLists
//
//  Created by Otávio Zabaleta on 22/10/2024.
//

import UIKit
import SwiftUI

extension View {
    func snapshot() -> UIImage? {
        let controller = UIHostingController(
            rootView: self.ignoresSafeArea().fixedSize(horizontal: true, vertical: true))
        guard let view = controller.view else { return nil }
        
        let targetSize = view.intrinsicContentSize // to capture entire scroll content
        if targetSize.width <= 0 || targetSize.height <= 0 { return nil }
        
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .systemTeal // set it to clear if no background color is preffered
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { rendereContext in
            view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
