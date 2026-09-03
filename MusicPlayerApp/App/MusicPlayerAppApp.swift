//
//  MusicPlayerAppApp.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/9/24.
//

import SwiftUI

@main
struct MusicPlayerAppApp: App {
    
    private let audioPlayerStore = AudioPlayerStore()
    private let fileManagerStore = FileManagerStore()
    private let startUpStore = try! StartUpStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Track.self, Playlist.self, Favorites.self])
                .environment(\.audioPlayerStore, audioPlayerStore)
                .environment(\.fileManagerStore, fileManagerStore)
                .environment(\.startUpStore, startUpStore)
                .preferredColorScheme(.dark)
                .withToast()
        }
    }
}
