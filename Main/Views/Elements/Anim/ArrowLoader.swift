//
//  ArrowLoader.swift
//  Outline
//
//  Created by Diesperov Konstantin on 03.11.2025.
//

import SwiftUI

class ArrowLoader: NSObject, ObservableObject{
    @Published var uiImage: UIImage?
    
    private enum Phase { case start, loading, success, cansel }
    private var phase: Phase = .start
    
    private var frames: [UIImage] = []
    private let startFrames: [UIImage]
    private let loadingFrames: [UIImage]
    private let successFrames: [UIImage]
    //private let canselFrames: [UIImage]
    
    private var fps: Double
    private var frameTime: Double { 1.0 / max(1, fps) }
    private var lastTime: CFTimeInterval = 0
    private var deltaTime: Double = 0
    private var i = 0;
    private var link: CADisplayLink?
    private var isStopped = false
    
    init(_ fps: Double){
        self.fps = fps
        
        startFrames = (0..<20).compactMap { UIImage(named: "arrow_\($0)") }
        uiImage = startFrames.first
        self.frames = startFrames
        
        loadingFrames = (20..<32).compactMap { UIImage(named: "arrow_\($0)") }
        successFrames = (32..<46).compactMap { UIImage(named: "arrow_\($0)") }
    }
    
    func play(){
        guard link == nil, !frames.isEmpty else { return }
        phase = .start
        switchTo(frames: startFrames)
        
        lastTime = CACurrentMediaTime()
        let l = CADisplayLink(target: self, selector: #selector(tick))
        l.preferredFramesPerSecond = Int(fps)
        l.add(to: .main, forMode: .common)
        link = l
    }
    
    @objc private func tick(_ link: CADisplayLink) {
        if isStopped { return }
        guard !frames.isEmpty else { return }

        let now = CACurrentMediaTime()
        deltaTime += max(0, now - lastTime)
        lastTime = now

        while deltaTime >= frameTime {
            deltaTime -= frameTime

            if phase == .start && !DiStatus.shared.loading && DiStatus.shared.connected
                && i + 1 >= frames.count - 1 {
                phase = .success
                switchTo(frames: successFrames)
                continue
            }

            i += 1

            if i >= frames.count {
                switch phase {
                case .start:
                    if DiStatus.shared.loading {
                        phase = .loading
                        switchTo(frames: loadingFrames)
                        continue
                    } else if DiStatus.shared.connected {
                        phase = .success
                        switchTo(frames: successFrames)
                        continue
                    } else {
                        stop()
                        return
                    }

                case .loading:
                    if DiStatus.shared.loading {
                        i = 0
                    } else if DiStatus.shared.connected {
                        phase = .success
                        switchTo(frames: successFrames)
                        continue
                    } else {
                        stop()
                        return
                    }

                case .success, .cansel:
                    i = max(0, frames.count - 1)
                    finnal()
                    return
                }
            }
        }

        if !frames.isEmpty {
            let safe = min(i, frames.count - 1)
            if Thread.isMainThread { uiImage = frames[safe] }
            else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.uiImage = self.frames[safe]
                }
            }
        }
    }


    
    func finnal(){
        isStopped = true
        link?.invalidate()
        link = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.uiImage = frames[frames.count - 1]
            self.isStopped = false
        }
    }
    
    func stop()
    {
        isStopped = true
        
        link?.invalidate()
        link = nil
        
        switchTo(frames: startFrames)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.uiImage = self.startFrames.first
            self.isStopped = false
        }
    }
    
    private func switchTo(frames newFrames: [UIImage]) {
        guard !newFrames.isEmpty else { return }
        frames = newFrames
        i = 0
        deltaTime = 0
        lastTime = CACurrentMediaTime()
        uiImage = newFrames[i]
    }
}
