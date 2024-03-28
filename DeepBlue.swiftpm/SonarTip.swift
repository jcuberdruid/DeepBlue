//
//  SonarTip.swift
//  DeepBlue
//
//  Created by eos on 2/20/24.
//

import SwiftUI
import TipKit

struct SonarTip: Tip {
    /// Display every time :)
    var id = "sonarUsageTip\(Int.random(in: 1...10000))"
    
    var title: Text {
        Text("Ping with Sonar")
    }


    var message: Text? {
        Text("Use sonar to find the research sea base and complete the game.")
    }


    var image: Image? {
        Image(systemName: "info.circle.fill")
    }
}
