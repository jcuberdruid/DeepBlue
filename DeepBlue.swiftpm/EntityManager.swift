//
//  EntityManager.swift
//  DeepBlue
//
//  Created by eos on 2/15/24.
//

import Foundation
import UIKit
import RealityKit

class EntityManager: ObservableObject {
    public var arView: ARView?
    var camera: PerspectiveCamera?
    
    var submarine: Entity?
    var submarineComponent: SubmarineComponent?
    
    var seaBase: Entity?
    var seaBaseComponent: SeaBaseComponent?
    
    func makeCamera() -> AnchorEntity {
        let cameraAnchor = AnchorEntity(world: [0, 0, 0])
        
        let perspectiveCamera = PerspectiveCamera()
        perspectiveCamera.transform.rotation = .init(angle: -Float.pi / 2.5, axis: .init(x: 1, y: 0, z: 0))
        self.camera = perspectiveCamera
        cameraAnchor.addChild(perspectiveCamera)
        return cameraAnchor
    }
    func makeTerrain() -> AnchorEntity {
        let terrainAnchor = AnchorEntity(world: [0, -200, 0])
        
        guard let terrainURL = Bundle.main.url(forResource: "medium_simplified_terrain", withExtension: "usdc") else {
            fatalError("Failed to init terrain resource URL")
        }
        
        guard let terrainEntity = try? Entity.load(contentsOf: terrainURL) else {
            fatalError("Failed to load terrain entity from URL")
        }
        
        guard let modelEntity = terrainEntity.children[0].children[0] as? ModelEntity else {
            fatalError("Failed to get ModelEntity from terrain entity")
        }
        
        var material = PhysicallyBasedMaterial()
        material.roughness = .init(floatLiteral: 1)
        material.metallic = .init(floatLiteral: 0.5)
        material.clearcoat = .init(floatLiteral: 0)
        material.baseColor = .init(tint: UIColor(displayP3Red: 0.3, green: 0.5, blue: 0.8, alpha: 1))
        modelEntity.model?.materials = [material]
        
        terrainEntity.scale = .init(2, 2, 1)
        terrainEntity.generateCollisionShapes(recursive: true)
        
        terrainAnchor.addChild(terrainEntity)
        return terrainAnchor
    }

    func makeSubmarine(gameState: GameState) -> AnchorEntity {
        let submarineAnchor = AnchorEntity(world: [550, 0, 550])
        
        guard let submarineURL = Bundle.main.url(forResource: "clay_submarine", withExtension: "usdz") else {
            fatalError("Failed to init submarine resource URL")
        }
        
        guard let submarineEntity = try? Entity.load(contentsOf: submarineURL) else {
            fatalError("Failed to load submarine entity from URL")
        }
        
        submarineEntity.scale = .init(50, 50, 50)
        
        submarineEntity.generateCollisionShapes(recursive: true)
        
        let spotLight = SpotLight()
        spotLight.light.color = .green
        spotLight.light.intensity = 550000000
        spotLight.light.innerAngleInDegrees = 70
        spotLight.light.outerAngleInDegrees = 120
        spotLight.light.attenuationRadius = 700
        spotLight.shadow = SpotLightComponent.Shadow()
        spotLight.orientation = .init(angle: -Float.pi / 3, axis: .init(x: 1, y: 0, z: 0))
        spotLight.position.y = -1
        submarineEntity.addChild(spotLight)

        let component = SubmarineComponent(gameState: gameState)
        submarineEntity.components.set([component])
        
        self.submarine = submarineEntity
        self.submarineComponent = component
        
        submarineAnchor.addChild(submarineEntity)
        return submarineAnchor
    }
    
    func makeSeaBase() -> AnchorEntity {
        let seaBaseAnchor = AnchorEntity(world: [-482, -70, -50])
        
        guard let seaBaseURL = Bundle.main.url(forResource: "simplified_clay_seabase", withExtension: "usdz") else {
            fatalError("Failed to init seabase resource URL")
        }
        
        guard let seaBaseEntity = try? Entity.load(contentsOf: seaBaseURL) else {
            fatalError("Failed to load seabase entity from URL")
        }

        seaBaseEntity.scale = .init(500, 500, 500)
        seaBaseEntity.orientation = (
            .init(angle: -Float.pi / 2, axis: .init(x: 0, y: 0, z: 1))
            * .init(angle: -Float.pi / 2, axis: .init(x: 0, y: 1, z: 0))
        )
        
        let component = SeaBaseComponent()
        seaBaseEntity.components.set([component])
        
        self.seaBase = seaBaseEntity
        self.seaBaseComponent = component
        
        seaBaseAnchor.addChild(seaBaseEntity)
        return seaBaseAnchor
    }
}
