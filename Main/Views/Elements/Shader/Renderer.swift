//
//  Renderer.swift
//  DiVPN
//
//  Created by Diesperov Konstantin on 13.01.2026.
//

import Foundation
import MetalKit

final class Renderer: NSObject, MTKViewDelegate{
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    var vertexBuffer: MTLBuffer
    var texture: MTLTexture
    var mask: MTLTexture
    var sampler: MTLSamplerState
    var startTime = CACurrentMediaTime()
    
    var scroll: Float = 0
    var scrollSpeedConnected: Float = 0.0005
    var scrollSpeedLoading: Float = 0.01
    
    let activeUIColor = UIColor(named: "ForceActive")!
    let defaultUIColor = UIColor(named: "TextSecondary")!
    
    init(_ parent: MetalViewRepresentable){
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        
        let library = device.makeDefaultLibrary()!
        let vertexFn = library.makeFunction(name: "vertex_main")
        let fragmentFn = library.makeFunction(name: "fragment_main")
        
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFn
        pipelineDesc.fragmentFunction = fragmentFn
        pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let attachment = pipelineDesc.colorAttachments[0]!
        attachment.isBlendingEnabled = true
        attachment.rgbBlendOperation = .add
        attachment.alphaBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment.sourceAlphaBlendFactor = .one
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        let vertices: [Float] = [
        //  x,y,    u,v,
            -1,-1,  0,1,
             1,-1,  1,1,
             -1,1,  0,0,
             
             1,-1,  1,1,
             1,1,    1,0,
             -1,1,  0,0
        ]
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])!
        
        let loader = MTKTextureLoader(device: device)
        guard let uiImage = UIImage(named: "vpn_pattern_tex"),
              let cgImageOrig = uiImage.cgImage,
              let cgImage = Renderer.cgImageToRGBA8(cgImageOrig),
              let uiMask = UIImage(named: "pattern_mask"),
              let cgMaskOrig = uiMask.cgImage,
              let cgMask = Renderer.cgImageToRGBA8(cgMaskOrig)  else {
            fatalError("Текстура vpn_pattern_tex не найдена или не декодируется")
        }
        texture = try! loader.newTexture(cgImage: cgImage, options: [MTKTextureLoader.Option.SRGB: false])
        mask = try! loader.newTexture(cgImage: cgMask, options: [MTKTextureLoader.Option.SRGB: false])
        
        let samplerDesc = MTLSamplerDescriptor()
        samplerDesc.minFilter = .linear
        samplerDesc.magFilter = .linear
        samplerDesc.sAddressMode = .repeat
        samplerDesc.tAddressMode = .repeat
        sampler = device.makeSamplerState(descriptor: samplerDesc)!
        
        super.init()
    }
    
    func draw(in view: MTKView){
        guard
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor
        else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        let connected = DiStatus.shared.connectedInterpolate
        let loading = DiStatus.shared.loadingInterpolate
        
        scroll += scrollSpeedConnected * connected + scrollSpeedLoading * loading
        //scroll = fmod(scroll, 1.0)
        
        var uniforms = Uniforms(
            time: Float(CACurrentMediaTime() - startTime),
            connected: connected,
            loading: loading,
            scroll: scroll,
            activeColor: SIMD4<Float>(colorToSIMD(activeUIColor)),
            defaultColor: SIMD4<Float>(colorToSIMD(defaultUIColor)));
        
        let uniformBuffer = device.makeBuffer(
            bytes: &uniforms,
            length: MemoryLayout<Uniforms>.size,
            options: []
        )!
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)!
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentTexture(mask, index: 1)
        encoder.setFragmentSamplerState(sampler, index: 0)
        encoder.setFragmentBuffer(uniformBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange sizee: CGSize){
        
    }
    
    static func cgImageToRGBA8(_ image: CGImage) -> CGImage? {
        let width = image.width
        let height = image.height
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()
    }
    
    func colorToSIMD(_ color: UIColor) -> SIMD4<Float> {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return SIMD4<Float>(Float(r), Float(g), Float(b), Float(a))
    }
}

struct Uniforms {
    var time: Float
    var connected: Float
    var loading: Float
    var scroll: Float
    var activeColor: SIMD4<Float>
    var defaultColor: SIMD4<Float>
}
