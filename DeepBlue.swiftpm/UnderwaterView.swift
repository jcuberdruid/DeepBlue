//
//  UnderwaterView.swift
//  DeepBlue
//
//  Created by eos on 2/09/24.
//

import SwiftUI
import RealityKit
import TipKit

struct UnderwaterView: View {
    @StateObject private var entityManager = EntityManager()
    @EnvironmentObject var gameState: GameState
    @Binding var menuDismissed: Bool
    @State var movementCount = 0
    @State var sonarCount = 0
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    var movementTip = MovementTip()
    var sonarTip = SonarTip()
    
    var body: some View {
        ZStack {
            ARViewWrapper(entityManager: entityManager, gameState: gameState)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture(coordinateSpace: .global) { location in
                    if !menuDismissed {
                        return
                    }
                    guard let arView = entityManager.arView else {
                        print("We got tapped with no ARView, oh no")
                        return
                    }
                    
                    guard let ray = arView.ray(through: location) else {
                        return
                    }
                    
                    let results = arView.scene.raycast(origin: ray.origin, direction: ray.direction, length: 5000.0, query: .nearest)
                    
                    if let result = results.first {
                        withAnimation {
                            movementCount += 1
                        }
                        var targetPosition = result.position
                        if let existingY = entityManager.submarine?.position.y {
                            targetPosition.y = existingY
                        }
                        entityManager.submarineComponent?.currentMovementTarget = targetPosition
                    } else {
                        print("No entity was hit by the raycast")
                    }
                }
            if menuDismissed {
                VStack {
                    if movementCount < 3 {
                        if #available(iOS 17.0, *) {
                            TipView(movementTip, arrowEdge: .bottom)
                        } else {
                            Text("Tap on the seafloor to move your sub")
                                .foregroundStyle(.white)
                        }
                    }
                    Spacer()
                    if sonarCount == 0 {
                        if #available(iOS 17.0, *) {
                            TipView(sonarTip, arrowEdge: .bottom)
                        } else {
                            Text("Sonar")
                                .foregroundStyle(.white)
                        }
                    }
                    Image(systemName: "antenna.radiowaves.left.and.right.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .onTapGesture {
                            withAnimation {
                                sonarCount += 1
                            }
                            feedbackGenerator.impactOccurred(intensity: 0.8)
                            entityManager.seaBaseComponent?.sonarRequest = true
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .padding()
                .task {
                    if #available(iOS 17.0, *) {
                        try? Tips.configure([
                            .displayFrequency(.immediate),
                            .datastoreLocation(.applicationDefault)
                        ])
                    }
                }
            }
        }
    }
}

struct ARViewWrapper: UIViewRepresentable {
    var entityManager: EntityManager
    var gameState: GameState
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.cameraMode = .nonAR
        
        SubmarineComponent.registerComponent()
        SubmarineSystem.registerSystem()
        
        SeaBaseComponent.registerComponent()
        SeaBaseSystem.registerSystem()
        
        self.entityManager.arView = arView
        
        let cameraAnchor = self.entityManager.makeCamera()
        arView.scene.anchors.append(cameraAnchor)
        
        let terrainAnchor = self.entityManager.makeTerrain()
        arView.scene.anchors.append(terrainAnchor)
        
        let submarineAnchor = self.entityManager.makeSubmarine(gameState: gameState)
        arView.scene.anchors.append(submarineAnchor)
        
        let seaBaseAnchor = self.entityManager.makeSeaBase()
        arView.scene.anchors.append(seaBaseAnchor)
        
        let postProcess = UnderwaterPostProcess()

        arView.renderCallbacks.prepareWithDevice = postProcess.prepareWithDevice
        arView.renderCallbacks.postProcess = postProcess.postProcess
        
        arView.environment.lighting.resource = try! .load(named: "ImageBasedLight.exr")
        
        /// The postprocessing shader ends up looking quite different when using `compatibleTargetTexture` on older-than-A12 devices (and Simulators), so compensate for that.
        if let isNativeTargetTexture = MTLCreateSystemDefaultDevice()?.supportsFamily(.apple5), isNativeTargetTexture {
            arView.environment.lighting.intensityExponent = 1
        } else {
            arView.environment.lighting.intensityExponent = 2.2
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}
