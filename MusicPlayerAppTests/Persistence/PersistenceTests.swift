import Foundation
import SwiftData
import Testing
@testable import MusicPlayerApp

@MainActor
struct PersistenceTests {
    @Test("Startup creates exactly one Favorites collection")
    func startupSeedsFavoritesIdempotently() throws {
        let container = try TestFactory.makeContainer()
        let context = container.mainContext

        try StartUpStore.ensureFavoritesExists(in: context)
        try StartUpStore.ensureFavoritesExists(in: context)

        let favorites = try context.fetch(FetchDescriptor<Favorites>())
        #expect(favorites.count == 1)
        #expect(favorites.first?.title == "Favorites")
    }

    @Test("Deleting a track does not delete its playlist")
    func deletingTrackPreservesPlaylist() throws {
        let container = try TestFactory.makeContainer()
        let context = container.mainContext
        let playlist = Playlist(id: UUID(), title: "Keep Me")
        let track = TestFactory.makeTrack()
        playlist.addTrack(track)
        context.insert(playlist)
        context.insert(track)
        try context.save()

        context.delete(track)
        try context.save()

        let playlists = try context.fetch(FetchDescriptor<Playlist>())
        let savedPlaylist = try #require(playlists.first { $0.id == playlist.id })
        #expect(savedPlaylist.trackList.isEmpty)
    }

    @Test("Deleting a playlist preserves its tracks")
    func deletingPlaylistPreservesTracks() throws {
        let container = try TestFactory.makeContainer()
        let context = container.mainContext
        let playlist = Playlist(id: UUID(), title: "Temporary")
        let track = TestFactory.makeTrack()
        playlist.addTrack(track)
        context.insert(playlist)
        context.insert(track)
        try context.save()

        context.delete(playlist)
        try context.save()

        let tracks = try context.fetch(FetchDescriptor<Track>())
        #expect(tracks.contains { $0.id == track.id })
    }
}
