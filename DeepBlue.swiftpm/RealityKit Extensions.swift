//
//  Extensions.swift
//  DeepBlue
//
//  Created by eos on 2/15/24.
//

import Foundation
import RealityKit
import Metal

extension ARView.PostProcessContext {
    var compatibleTargetTexture: MTLTexture! {
        if self.device.supportsFamily(.apple5) {
            return targetColorTexture
        } else {
            return targetColorTexture.makeTextureView(pixelFormat: .bgra8Unorm)!
        }
    }
}
