//
//  MenuView.swift
//  DeepBlue
//
//  Created by eos on 2/24/24.
//

import SwiftUI

struct IntroView: View {
    @Binding var menuDismissed: Bool
    var body: some View {
        VStack {
            Text("Welcome to DeepBlue")
                .font(.system(.title2))
        }
        .frame(maxWidth: 250)
        .padding()
        .background(Color.init(cgColor: .init(
            red: 0.5,
            green: 0.5,
            blue: 0.6,
            alpha: 0.8
        )), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(menuDismissed ? 0 : 1)
        .transition(.scale)
    }
}
