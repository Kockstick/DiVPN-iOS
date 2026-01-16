//
//  MetalViewRepresentable.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 13.01.2026.
//

import SwiftUI
import Foundation
import MetalKit

struct MetalViewRepresentable: UIViewRepresentable{
    func makeUIView(context: Context) -> MTKView{
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        if let device = MTLCreateSystemDefaultDevice(){
            mtkView.device = device
        }
        mtkView.enableSetNeedsDisplay = true
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        mtkView.framebufferOnly = false
        mtkView.isOpaque = false
        mtkView.isPaused = false
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context){
        
    }
    
    func makeCoordinator() -> Renderer {
        return Renderer(self)
    }
}
