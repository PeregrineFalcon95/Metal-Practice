//
//  ViewController.swift
//  Metaltest
//
//  Created by Mac mini on 11/1/21.
//

import UIKit
import Metal
import QuartzCore
import MetalKit

class ViewController: UIViewController {

    struct Vertex {
        var position: simd_float3
        var color: simd_float4
    }
    
    var device : MTLDevice!
    var metalLayer : CAMetalLayer!
    var vertexBuffer : MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    var vertexData : [Vertex]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        createVertexData()
        createBuffer()
        
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary!.makeFunction(name: "basic_fragment_shader")
        let vertexProgram = defaultLibrary!.makeFunction(name: "basic_vertex_shader")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
        try pipelineState = device.makeRenderPipelineState(descriptor:
        pipelineStateDescriptor)
        } catch let error {
        print("Failed to create pipeline state, error \(error)")
        }
        commandQueue = device.makeCommandQueue()
        
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }
    
    func createVertexData()
    {
        vertexData =
        [
            Vertex(position: simd_float3(0.0 , 0.5, 0.0 ), color: simd_float4(1, 0, 0, 1)),
            Vertex(position: simd_float3(-0.5, -0.5, 0.0), color: simd_float4(0, 1, 0, 1)),
            Vertex(position: simd_float3(0.5, -0.5, 0.0 ), color: simd_float4(0, 0, 1, 1))
        ]
    }
    
    func createBuffer()
    {
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) 
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    }
    
    func render()
    {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let drawable = metalLayer.nextDrawable() else {return}
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 221.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1.0)
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    @objc func gameloop()
    {
        autoreleasepool
        {
            self.render()
        }
    }
}

