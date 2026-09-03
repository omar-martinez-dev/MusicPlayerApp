//
//  DatabaseObserver.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 4/15/25.
//

import Foundation
import SwiftUI
import SwiftData

actor DatabaseObserver {
    func startObserving(
        audioplayerStore: AudioPlayerStore,
        allTracks: @escaping () -> [Track],
        favorites: @escaping () -> [Favorites],
        playlists: @escaping () -> [Playlist]
    ) {
        Task {
            let stream = NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange)
            
            for await _ in stream {
                await MainActor.run {
                    audioplayerStore.updateTrackList(
                        allTracks: allTracks(),
                        favorites: favorites(),
                        playlists: playlists()
                    )
                }
            }
        }
    }
}
