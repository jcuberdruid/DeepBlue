//
//  SubmarineSystem.swift
//  DeepBlue
//
//  Created by eos on 2/18/24.
//

import Foundation
import RealityKit
import SwiftUI

class SeaBaseComponent: Component {
    var sonarRequest: Bool = false
    var currentSonarScale: Float = 1
    var currentSonarEntity: Entity?
    
    func createSonar(entity: Entity) {
        cleanupSonar()

        sonarRequest = false
        let sphereMesh = MeshResource.generateSphere(radius: 0.1)
        var material = PhysicallyBasedMaterial()
        material.roughness = .init(floatLiteral: 0.5)
        material.metallic = .init(floatLiteral: 0.5)
        material.clearcoat = .init(floatLiteral: 0.5)
        material.baseColor = .init(tint: UIColor.systemGreen)
        material.blending = .transparent(opacity: .init(floatLiteral: 0.5))

        let sonarEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        self.currentSonarEntity = sonarEntity
        self.currentSonarScale = 1
        
        entity.addChild(sonarEntity)
    }
    func updateSonar() {
        guard let entity = currentSonarEntity else {
            return
        }
        entity.scale = .init(currentSonarScale, currentSonarScale, currentSonarScale)
        currentSonarScale += 0.3
        if (currentSonarScale > 28) {
            cleanupSonar()
        }
    }
    func cleanupSonar() {
        if let existingEntity = currentSonarEntity {
            existingEntity.removeFromParent()
        }
    }
}

class SeaBaseSystem: System {
    private static let query = EntityQuery(where: .has(SeaBaseComponent.self))
    private static let cameraQuery = EntityQuery(where: .has(PerspectiveCameraComponent.self))

    required init(scene: RealityKit.Scene) {
    }
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let seaBaseComponent = entity.components[SeaBaseComponent.self] as? SeaBaseComponent else {
                fatalError("Unexpectedly missing sea base component")
            }
            
            if seaBaseComponent.sonarRequest {
                seaBaseComponent.createSonar(entity: entity)
            }
            seaBaseComponent.updateSonar()
        }
    }
}
