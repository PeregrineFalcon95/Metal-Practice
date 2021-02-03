//
//  MetalImageFilter.swift
//  Invert Color filter with Metal
//
//  Created by Mac mini on 31/1/21.
//

import Foundation
import MetalKit

class MetalImageFilter {
    private let device: MTLDevice
    private let library: MTLLibrary

    init?()
    {
        guard let _device = MTLCreateSystemDefaultDevice() else {return nil}
        device = _device

        do
        {
            let bundle = Bundle(for: MetalImageFilter.self)
            library = try device.makeDefaultLibrary(bundle: bundle)
        }
        catch
        {
            return nil
        }
    }
    public func imageInvertColors( of image: UIImage ) -> UIImage
    {
        //Creating compute pipeline with shader kernel function
        let function = library.makeFunction(name: "drawWithInvertedColor")!
        let computePipeline = try! device.makeComputePipelineState(function: function)
        
        //Making texture for shader
        let textureLoader = MTKTextureLoader(device: device)
        let inputTexture = try! textureLoader.newTexture(cgImage: image.cgImage!)
        let width = inputTexture.width
        let height = inputTexture.height
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm_srgb, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        //Creating blank writabler texture
        let outputTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        //Making command queue and configaring buffer
        let commandQueue = device.makeCommandQueue()!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        commandEncoder.setComputePipelineState(computePipeline)
        //First and second perameter
        commandEncoder.setTexture(inputTexture, index: 0)
        commandEncoder.setTexture(outputTexture, index: 1)

        let threadsPerThreadGroup = MTLSize(width: 16, height: 16, depth: 1)
        let threadgroupsPerGrid = MTLSize(width: width/16 + 1, height: height/16 + 1, depth: 1)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)

        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        //Converting texture to CIImage
        let ciImg = CIImage(mtlTexture: outputTexture)!.oriented(.downMirrored)
        let invertedImage = UIImage(ciImage: ciImg)
        return invertedImage
    }
}
