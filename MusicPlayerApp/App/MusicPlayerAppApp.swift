//
//  MusicPlayerAppApp.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/9/24.
//

import SwiftUI
import SwiftData

@main
struct MusicPlayerAppApp: App {
    
    private let audioPlayerStore = AudioPlayerStore()
    private let fileManagerStore = FileManagerStore()
    private let modelContainer: ModelContainer?
    private let startupErrorMessage: String?

    init() {
        do {
            modelContainer = try StartUpStore.makeContainer()
            startupErrorMessage = nil
        } catch {
            modelContainer = nil
            startupErrorMessage = error.localizedDescription
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                ContentView()
                    .modelContainer(modelContainer)
                    .environment(audioPlayerStore)
                    .environment(fileManagerStore)
                    .preferredColorScheme(.dark)
                    .withToast()
            } else {
                ContentUnavailableView(
                    "Unable to Open Music Library",
                    systemImage: "externaldrive.badge.exclamationmark",
                    description: Text(startupErrorMessage ?? "The music library could not be opened.")
                )
            }
        }
    }
}
