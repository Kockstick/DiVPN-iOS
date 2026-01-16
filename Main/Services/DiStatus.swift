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
    
    private var _loading: Bool = false
    public var loading: Bool {
        get{
            return _loading
        }
        set{
            if !newValue{
                isEnabled = connected
            }
            _loading = newValue
        }
    }
    
    @Published private(set) var connectedInterpolate: Float = 0
    @Published private(set) var loadingInterpolate: Float = 0
    private let speedInterpolation: Float = 3.0
    private var displayLink: CADisplayLink?
    
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
    
    private let connectedStartKey = "di.connected.start.time"
    private var connectedStartTime: TimeInterval?
    @Published private(set) var connectedDuration: TimeInterval = 0
    public var connectedTimeText: String {
        let totalSeconds = Int(connectedDuration)
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private init() {
        logger.i("DiStatus initialized", tag: LOG_TAG)
        startInterpolationLoop()
    }
    
    func setConnected(value: Bool) {
        let block = {
            self.logger.i("setConnected: \(value)", tag: self.LOG_TAG)
            self.connected = value
            self.loading = false
            
            if value {
                if let savedStart = UserDefaults.standard.object(forKey: self.connectedStartKey) as? TimeInterval {
                    self.connectedStartTime = savedStart
                } else {
                    let now = CACurrentMediaTime()
                    self.connectedStartTime = now
                    UserDefaults.standard.set(now, forKey: self.connectedStartKey)
                }
                
                self.connectedDuration = 0
            } else {
                self.connectedStartTime = nil
                self.connectedDuration = 0
                UserDefaults.standard.removeObject(forKey: self.connectedStartKey)
            }
        }
        
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async { block() }
        }
    }
    
    private func startInterpolationLoop() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateInterpolation))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateInterpolation() {
        let dt: Float = Float(displayLink?.duration ?? 0)
        
        let targetConnected: Float = connected ? 1 : 0
        connectedInterpolate += (targetConnected - connectedInterpolate) * min(1, speedInterpolation * dt)
        
        let targetLoading: Float = loading && !connected ? 1 : 0
        loadingInterpolate += (targetLoading - loadingInterpolate) * min(1, speedInterpolation * dt)
        
        if connected, let start = connectedStartTime {
                connectedDuration = CACurrentMediaTime() - start
            }
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
