//
//  ContentView.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/9/24.
//

import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    
    @Environment(AudioPlayerStore.self) private var audioPlayerStore
    @Environment(FileManagerStore.self) private var fileManagerStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.showToast) private var showToast
    
    @Query private var allTracks: [Track]
    @Query private var favorites: [Favorites]
    @Query private var playlists: [Playlist]
    
    private var favoriteTrackIDs: [UUID] {
        favorites.flatMap(\.trackList).map(\.id)
    }

    private var playlistRevision: [UUID] {
        playlists.flatMap { [$0.id] + $0.trackList.map(\.id) }
    }
        
    var body: some View {
        TabView {
            TracksScreen()
                .tabItem {
                    Label("Tracks", systemImage: "music.note")
                }
            
            PlaylistScreen()
                .tabItem {
                    Label("Playlist", systemImage: "music.note.list")
                }
        }
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .onAppear {
            audioPlayerStore.showToast = showToast
            if audioPlayerStore.currentTrack == nil {
                audioPlayerStore.playbackSource = .allTracks
            }
            refreshPlaybackQueue()
        }
        .onChange(of: allTracks.map(\.id)) { refreshPlaybackQueue() }
        .onChange(of: favoriteTrackIDs) { refreshPlaybackQueue() }
        .onChange(of: playlistRevision) { refreshPlaybackQueue() }
        .onChange(of: audioPlayerStore.playbackSource) { refreshPlaybackQueue() }
        .task {
            await restoreMissingArtwork()
        }
    }

    private func refreshPlaybackQueue() {
        audioPlayerStore.updateTrackList(
            allTracks: allTracks,
            favorites: favorites,
            playlists: playlists
        )
    }

    private func restoreMissingArtwork() async {
        var restoredArtwork = false

        for track in allTracks where track.artwork == nil {
            do {
                try Task.checkCancellation()
                if let artwork = try await fileManagerStore.embeddedArtwork(forFileNamed: track.fileName) {
                    track.artwork = artwork
                    restoredArtwork = true
                }
            } catch is CancellationError {
                return
            } catch {
                continue
            }
        }

        guard restoredArtwork else { return }
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Some track artwork could not be restored"))
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
        .modelContainer(SampleData.shared.modelContainer)
        .environment(AudioPlayerStore())
        .environment(FileManagerStore())
        .withToast()
}
