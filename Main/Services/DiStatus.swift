//
//  DiStatus.swift
//  Outline
//
//  Created by Diesperov Konstantin on 12.08.2025.
//

import Swift
import SwiftUI

final class DiStatus: ObservableObject {
    static let shared = DiStatus()
    
    private let LOG_TAG: String = "DiStatus"
    private let logger = DiLogger.shared
    
    @Published var isEnabled: Bool = false
    
    @Published var connected: Bool = false
    
    @Published public var loading: Bool = false
    
    public var statusText: String {
        if connected {
            if loading {
                return NSLocalizedString("disconnecting", comment: "")
            } else {
                return NSLocalizedString("connected", comment: "")
            }
        }
        else{
            if loading {
                return NSLocalizedString("connecting", comment: "")
            } else {
                return NSLocalizedString("disconnected", comment: "")
            }
        }
    }
    
    private init() {
        logger.i("DiStatus initialized", tag: LOG_TAG)
    }
    
    func setConnected(value: Bool) {
        if Thread.isMainThread {
            logger.i("setConnected called on main thread: \(value)", tag: LOG_TAG)
            self.connected = value
            loading = false
        } else {
            logger.w("setConnected called off main thread, dispatching to main: \(value)", tag: LOG_TAG)
            DispatchQueue.main.async {
                self.connected = value
                self.loading = false
            }
        }
    }
}
