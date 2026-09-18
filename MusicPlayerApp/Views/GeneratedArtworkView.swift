//
//  GeneratedArtworkView.swift
//  MusicPlayerApp
//

import SwiftUI

struct GeneratedArtworkView: View {
    let title: String
    let artist: String

    private var primaryColor: Color {
        Color(hue: hue, saturation: 0.72, brightness: 0.78)
    }

    private var secondaryColor: Color {
        Color(hue: (hue + 0.16).truncatingRemainder(dividingBy: 1), saturation: 0.82, brightness: 0.48)
    }

    private var hue: Double {
        let seed = (title + artist).unicodeScalars.reduce(0) { partialResult, scalar in
            (partialResult &* 31 &+ Int(scalar.value)) % 360
        }
        return Double(seed) / 360
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [primaryColor, secondaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.14))
                .scaleEffect(0.72)
                .offset(x: 22, y: -18)

            Image(systemName: "music.note")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.9))
                .padding()
        }
        .clipShape(.rect(cornerRadius: 10))
        .accessibilityHidden(true)
    }
}

#Preview {
    GeneratedArtworkView(title: "Alla Turca", artist: "Wolfgang Amadeus Mozart")
        .frame(width: 180, height: 180)
        .padding()
}
