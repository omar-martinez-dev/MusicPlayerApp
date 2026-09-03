//
//  Playlist.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/19/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Playlist: PlaylistType, Identifiable {

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
        }
    }
    
    func removeTrack(_ track: Track) {
        trackList.removeAll(where: { $0.id == track.id })
    }
    
    static let sampleData = [
        Playlist(id: UUID(), title: "Jazz"),
        Playlist(id: UUID(), title: "Rock Hits"),
        Playlist(id: UUID(), title: "Classical")
    ]
}
