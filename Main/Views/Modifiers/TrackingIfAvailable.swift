//
//  TrackingIfAvailable.swift
//  Outline
//
//  Created by Diesperov Konstantin on 16.08.2025.
//

import SwiftUI

struct TrackingIfAvailable: ViewModifier {
    var value: CGFloat = 3
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.tracking(value)
        } else {
            content
        }
    }
}

extension View {
    func trackingIfAvailable(value: CGFloat) -> some View {
        modifier(TrackingIfAvailable(value: value))
    }
}
