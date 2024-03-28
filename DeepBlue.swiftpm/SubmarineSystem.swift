//
//  SubmarineSystem.swift
//  DeepBlue
//
//  Created by eos on 2/15/24.
//

import Foundation
import RealityKit

class SubmarineComponent: Component {
    var gameState: GameState
    var currentMovementTarget: SIMD3<Float>?
    
    init(gameState: GameState, currentMovementTarget: SIMD3<Float>? = nil) {
        self.gameState = gameState
        self.currentMovementTarget = currentMovementTarget
    }

    func moveTowardsTarget(entity: Entity) {
        guard let target = currentMovementTarget else {
            return
        }
        
        let targetDistance = distance(entity.position(relativeTo: nil), target)
        if targetDistance < 5 {
            self.currentMovementTarget = nil
        }
        
        let direction = normalize(target - entity.position(relativeTo: nil))

        let localForward = SIMD3<Float>(0, -1, 0)
        let transformMatrix: float4x4 = entity.transformMatrix(relativeTo: nil)
        let rotationMatrix = simd_float3x3(
            SIMD3<Float>(transformMatrix.columns.0.x, transformMatrix.columns.0.y, transformMatrix.columns.0.z),
            SIMD3<Float>(transformMatrix.columns.1.x, transformMatrix.columns.1.y, transformMatrix.columns.1.z),
            SIMD3<Float>(transformMatrix.columns.2.x, transformMatrix.columns.2.y, transformMatrix.columns.2.z)
        )
        let globalForward = rotationMatrix * localForward
        
        let rotationAxis = cross(globalForward, direction)
        if simd_length(rotationAxis) > 0.1 {
            let dotProduct = dot(globalForward, direction)
            let angle = acos(min(max(dotProduct / (length(globalForward) * length(direction)), -1.0), 1.0))

            let rotationQuaternion = simd_quatf(angle: angle / 20, axis: normalize(rotationAxis))
            entity.orientation = rotationQuaternion * entity.orientation
        }
        let speedFactor = 0.7 * (simd_smoothstep(targetDistance, -10, 50) + 0.1)
        entity.position += normalize(globalForward) * speedFactor
        
    }
}

class SubmarineSystem: System {
    private static let query = EntityQuery(where: .has(SubmarineComponent.self))
    private static let cameraQuery = EntityQuery(where: .has(PerspectiveCameraComponent.self))
    private static let seaBaseQuery = EntityQuery(where: .has(SeaBaseComponent.self))

    required init(scene: Scene) {
    }
    
    func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let submarineComponent = entity.components[SubmarineComponent.self] as? SubmarineComponent else {
                fatalError("Unexpectedly missing submarine component")
            }
            
            submarineComponent.moveTowardsTarget(entity: entity)
            
            context.scene.performQuery(Self.cameraQuery).forEach { cameraEntity in
                cameraEntity.anchor?.position = entity.position(relativeTo: nil) + .init(x: 0, y: 500, z: 120)
            }
            
            context.scene.performQuery(Self.seaBaseQuery).forEach { seaBaseEntity in
                let submarinePosition = entity.position(relativeTo: nil)
                let seaBasePosition = seaBaseEntity.position(relativeTo: nil)
                if abs(submarinePosition.x - seaBasePosition.x) + abs(submarinePosition.z - seaBasePosition.z) < 200 {
                    submarineComponent.gameState.won = true
                }
            }
        }
    }
}
