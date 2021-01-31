//
//  ViewController.swift
//  Metal Practice
//
//  Created by Mac mini on 25/1/21.
//

import UIKit
import MetalKit
import Metal
import QuartzCore

class ViewController: UIViewController {
    
    var objectTodraw : Cube!
    
    var device : MTLDevice!
    var metalLayer : CAMetalLayer!
    var pipeLineState : MTLRenderPipelineState!
    var commandQueue : MTLCommandQueue!
    var timer : CADisplayLink!
    var projectionMatrix: Matrix4!

    var lastFrameTimestamp: CFTimeInterval = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)

        
        
        //Creating a system default device and a CAlayer. Adding the calayer as sublayer of views main layer
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm // 8 bytes for Blue, Green, Red and Alpha
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
       
        //Initializing the triangle object
        objectTodraw = Cube(device: device)
//        objectTodraw.positionX = 0.0
//        objectTodraw.positionY =  0.0
//        objectTodraw.positionZ = -2.0
//        objectTodraw.rotationZ = Matrix4.degrees(toRad: 45);
//        objectTodraw.scale = 0.5
        
        //Creating a library to hold the shader functions
        let defaultLibrary = device.makeDefaultLibrary()
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertex_shader")
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragment_shader")
        
        //PipeLine and pushing the shaders to pipeline
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments [ 0 ].pixelFormat = .bgra8Unorm
        
        pipeLineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        //Cadisplay link timer call the gameloop function everytime the display refreshes
        //timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer = CADisplayLink(target: self, selector: #selector(ViewController.newFrame(displayLink:)))

        timer.add(to: RunLoop.main, forMode: .default)
    }
    
//    @objc func gameloop()
//    {
//        autoreleasepool
//        {
//            self.render()
//        }
//    }
    // 1
    @objc func newFrame(displayLink: CADisplayLink){
        
      if lastFrameTimestamp == 0.0
      {
        lastFrameTimestamp = displayLink.timestamp
      }
        
      // 2
      let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
      lastFrameTimestamp = displayLink.timestamp
        
      // 3
      gameloop(timeSinceLastUpdate: elapsed)
    }
      
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        
      // 4
      objectTodraw.updateWithDelta(delta: timeSinceLastUpdate)
        
      // 5
      autoreleasepool {
        self.render()
      }
    }


    func render()
    {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAroundX(Matrix4.degrees(toRad: 25), y: 0.0, z: 0.0)
            
        objectTodraw.render(commandQueue: commandQueue, pipeLineState: pipeLineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)

    }
}

