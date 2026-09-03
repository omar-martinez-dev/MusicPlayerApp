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
    
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @Environment(\.fileManagerStore) private var fileManagerStore
    @Environment(\.showToast) private var showToast
    
    @Query private var allTracks: [Track]
    @Query private var favorites: [Favorites]
    @Query private var playlists: [Playlist]
    
    @State private var databaseObserver = DatabaseObserver()
    @State private var didStartObserving = false
        
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
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            if !didStartObserving {
                didStartObserving = true
                Task {
                    await databaseObserver.startObserving(
                        audioplayerStore: audioPlayerStore,
                        allTracks: { allTracks },
                        favorites: { favorites },
                        playlists: { playlists }
                    )
                }
            }
            audioPlayerStore.showToast = showToast
            fileManagerStore.showToast = showToast
            
            audioPlayerStore.allTracksProvider = { allTracks }
            audioPlayerStore.favoritesProvider = { favorites }
            audioPlayerStore.playlistsProvider = { playlists }

            if audioPlayerStore.currentTrack == nil {
                audioPlayerStore.playbackSource = .allTracks
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
        .modelContainer(SampleData.shared.modelContainer)
        .withToast()
}
