//
//  UnderwaterPostProcessing.swift
//  DeepBlue
//
//  Created by eos on 2/12/24.
//

import Foundation
import Metal
import RealityKit

class UnderwaterPostProcess {
    var pipeline: MTLComputePipelineState?
    var startTime: TimeInterval?
    
    func prepareWithDevice(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else {
            fatalError()
        }
        guard let kernel = library.makeFunction(name: "underwaterEffectCompute") else {
            fatalError()
        }
        self.startTime = Date.now.timeIntervalSince1970
        self.pipeline = try? device.makeComputePipelineState(function: kernel)
    }

    func postProcess(context: ARView.PostProcessContext) {
        guard let encoder = context.commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        guard let pipeline = self.pipeline else {
            return
        }
        
        let currentTime = Float(Date.now.timeIntervalSince1970 - (self.startTime ?? 0))
        var time = currentTime
        let timeBuffer = context.device.makeBuffer(bytes: &time, length: MemoryLayout<Float>.size, options: [])
        
        encoder.setComputePipelineState(pipeline)
        encoder.setTexture(context.sourceColorTexture, index: 0)
        encoder.setTexture(context.compatibleTargetTexture, index: 1)
        encoder.setBuffer(timeBuffer, offset: 0, index: 0)

        let threadsPerThreadgroup = MTLSize(
            width: pipeline.threadExecutionWidth,
            height: pipeline.maxTotalThreadsPerThreadgroup / pipeline.threadExecutionWidth,
            depth: 1
        )
        
        let threadgroupsPerGrid = MTLSize(
            width: (context.targetColorTexture.width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width,
            height: (context.targetColorTexture.height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height,
            depth: 1
        )
        
        encoder.dispatchThreadgroups(
            threadgroupsPerGrid,
            threadsPerThreadgroup: threadsPerThreadgroup
        )
        encoder.endEncoding()
    }
}
