//
//  Music.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/13/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Track: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var artist: String
    var album: String
    var duration: TimeInterval
    var fileName: String
    var artwork: Data?
    var favorite: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \Playlist.trackList) var playlists: [Playlist] = []
    
    var artworkImage: UIImage? {
        guard let data = artwork else { return nil }
        return UIImage(data: data)
    }
    
    init(id: UUID, title: String, artist: String, album: String, duration: TimeInterval, fileName: String, artwork: Data? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.fileName = fileName
        self.artwork = artwork
    }
    
    func markAsFavorite() {
        favorite = true
    }
    
    func unmarkAsFavorite() {
        favorite = false
    }
    
    static let sampleData = [
        Track(id: UUID(), title: "Thunderstruck", artist: "AC/DC", album: "Back in Black", duration: 242.0, fileName: "None"),
        Track(id: UUID(), title: "Shape of You", artist: "Ed Sheeran", album: "Divide", duration: 230.0, fileName: "None"),
        Track(id: UUID(), title: "All of Me", artist: "John Legend", album: "Love in the Future", duration: 220.0, fileName: "None"),
    ]
}
