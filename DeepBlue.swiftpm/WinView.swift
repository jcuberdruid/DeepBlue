//
//  MenuView.swift
//  DeepBlue
//
//  Created by eos on 2/24/24.
//

import SwiftUI

struct WinView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.largeTitle)
                .foregroundStyle(Color(uiColor: .green))
                .padding()

            Text("Thanks for playing DeepBlue")
                .fontWeight(.bold)
                        
            Text("Hope you enjoyed this mini underwater experience.")
                .padding(.vertical, 4)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 275)
        .padding()
        .background(Color.init(cgColor: .init(
            red: 0.5,
            green: 0.5,
            blue: 0.5,
            alpha: 0.8
        )), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .transition(.scale)
    }
}

#Preview {
    WinView()
}
