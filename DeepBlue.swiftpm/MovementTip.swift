//
//  SonarTip.swift
//  DeepBlue
//
//  Created by eos on 2/23/24.
//

import SwiftUI
import TipKit

struct MovementTip: Tip {
    /// Display every time :)
    var id = "movementTip\(Int.random(in: 1...10000))"
    
    var title: Text {
        Text("Move your sub")
    }


    var message: Text? {
        Text("Tap on the seafloor to move your sub.")
    }


    var image: Image? {
        Image(systemName: "move.3d")
    }
}
