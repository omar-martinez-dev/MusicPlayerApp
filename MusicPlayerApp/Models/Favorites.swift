//
//  Favorites.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 11/21/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Favorites: PlaylistType, Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    @Relationship(deleteRule: .nullify) var trackList: [Track] = []
    
    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
    
    func addTrack(_ track: Track) {
        if !trackList.contains(where: { $0.id == track.id }) {
            trackList.append(track)
            track.markAsFavorite()
        }
    }
    
    func removeTrack(_ track: Track) {
        trackList.removeAll(where: { $0.id == track.id })
        track.unmarkAsFavorite()
    }
    
    static let sampleData = [
        Favorites(id: UUID(), title: "Favorites")
    ]
}
