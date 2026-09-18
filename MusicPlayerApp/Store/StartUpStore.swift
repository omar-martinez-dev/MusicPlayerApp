//
//  StartUpStore.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 11/21/24.
//

import Foundation
import SwiftData

@MainActor
enum StartUpStore {
    static func makeContainer(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema([Track.self, Playlist.self, Favorites.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )
        let container = try ModelContainer(for: schema, configurations: [configuration])
        try ensureFavoritesExists(in: container.mainContext)
        return container
    }

    static func ensureFavoritesExists(in context: ModelContext) throws {
        let fetchDescriptor = FetchDescriptor<Favorites>(
            predicate: #Predicate { $0.title == "Favorites" }
        )

        let fetchedFavorites = try context.fetch(fetchDescriptor)
        if fetchedFavorites.isEmpty {
            context.insert(Favorites(id: UUID(), title: "Favorites"))
            try context.save()
        }
    }
}
