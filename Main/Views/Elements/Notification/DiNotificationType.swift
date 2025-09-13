//
//  DiNotificationType.swift
//  Outline
//
//  Created by Diesperov Konstantin on 21.08.2025.
//

import SwiftUI

enum DiNotificationType {
    case success
    case info
    case warning
    case error
    
    var color: Color {
        switch self {
        case .success: return Color("Active")
        case .info: return Color("Surface")
        case .warning: return Color("Accent")
        case .error: return Color("Error")
        }
    }
    
    var textColor: Color {
        switch self {
        case .info: return Color("TextPrimary")
        default: return Color("TextPrimaryFixed")
        }
    }
}
