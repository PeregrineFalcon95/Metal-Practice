//
//  Node.swift
//  Metal Practice
//
//  Created by Mac mini on 29/1/21.
//

import Foundation
import Metal
import QuartzCore

class Node
{
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0

    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale:     Float = 1.0

    var time:CFTimeInterval = 0.0

  
    init(name: String, vertices: Array<Vertex>, device: MTLDevice)
    {
        var vertexData = Array<Float>()
        for vertex in vertices
        {
            vertexData += vertex.floatBuffer()
        }
    
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
    
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    //Rendering Data to GPU
    func render( commandQueue: MTLCommandQueue, pipeLineState: MTLRenderPipelineState, drawable: CAMetalDrawable,  parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor? )
    {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments [ 0 ].texture = drawable.texture
        renderPassDescriptor.colorAttachments [ 0 ].loadAction = .clear
        renderPassDescriptor.colorAttachments [ 0 ].clearColor = MTLClearColor(red: 0.0, green: 104/255, blue: 55/255, alpha: 1.0)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        //For now cull mode is used instead of depth buffer
        renderEncoder.setCullMode(MTLCullMode.front)

        renderEncoder.setRenderPipelineState(pipeLineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        //Creating buffer for matrix
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2, options: [])

        let bufferPointer = uniformBuffer!.contents()
        memcpy(bufferPointer, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())


        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
    
    func modelMatrix() -> Matrix4
    {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWithDelta(delta: CFTimeInterval)
    {
        time += delta
    }


}
