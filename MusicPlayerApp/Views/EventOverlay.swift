//
//  EventOverlay.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 6/23/25.
//

import SwiftUI

struct EventOverlay: View {
    var event: AppEvent
    
    var body: some View {
        HStack(spacing: 10) {
            event.icon
                .foregroundStyle(.background)
            Text(event.message)
                .foregroundStyle(.background.quinary)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(event.color)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .padding(.horizontal, 16)
    }
}

#Preview {
    
    EventOverlay(event: .success(message: "Track(s) added to playlist"))
    
    EventOverlay(event: .error(message: "Unable to add track(s) to playlist"))
    
    EventOverlay(event: .info(message: "Duplicate tracks found and skipped"))
}
