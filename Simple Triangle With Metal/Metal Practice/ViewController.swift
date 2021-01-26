//
//  ViewController.swift
//  Metal Practice
//
//  Created by Mac mini on 25/1/21.
//

import UIKit
import MetalKit
import QuartzCore

class ViewController: UIViewController {

    let vertexData : [ Float ] =
    [
        0.0, 0.5, 0.0,
        -0.5, -0.5, 0.0,
        0.5, -0.5, 0.0
    ]
    
    var device : MTLDevice!
    var metalLayer : CAMetalLayer!
    var vertexBuffer : MTLBuffer!
    var pipelineState : MTLRenderPipelineState!
    var commandQueue : MTLCommandQueue!
    var timer : CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //System device for interecting with GPU and Metal layer
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        //Creating buffers for vertex data
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData [ 0 ] )
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        //Making library with shaders and adding them to Pipeline
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do
        {
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        }
        catch
        {
            print(error)
        }
        
        //Creating command queue
        commandQueue = device.makeCommandQueue()
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default )
    }
    
    @objc func gameloop()
    {
        autoreleasepool {
            self.render()
        }
    }
    
    func render()
    {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let drawable = metalLayer.nextDrawable() else {return}
        renderPassDescriptor.colorAttachments [0].texture = drawable.texture
        renderPassDescriptor.colorAttachments [0].loadAction = .clear
        renderPassDescriptor.colorAttachments [0].clearColor = MTLClearColor(red: 221/255, green: 160/255, blue: 221/255, alpha: 1.0)
        let commandBuffer = commandQueue.makeCommandBuffer()
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
}

