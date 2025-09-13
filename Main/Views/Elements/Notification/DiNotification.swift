//
//  NotificationManager.swift
//  Outline
//
//  Created by Diesperov Konstantin on 18.08.2025.
//

import SwiftUI

class DiNotification {
    static let shared = DiNotification()
    
    @Published private(set) var showRow: Bool = false
    @Published private(set) var rowText: String = ""
    @Published private(set) var rowType: DiNotificationType = .error
    
    func showRow(_ text: String, type: DiNotificationType = .error) {
        if showRow {
            return
        }
        rowText = text
        showRow = true
        rowType = type
    }
    
    func hideRow(_ text: String){
        if rowText != text {
            return
        }
        rowText = ""
        showRow = false
    }
}
