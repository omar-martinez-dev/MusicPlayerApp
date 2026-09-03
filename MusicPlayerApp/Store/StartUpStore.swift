//
//  StartUpStore.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 11/21/24.
//

import Foundation
import SwiftData

final class StartUpStore {
    let container: ModelContainer
    
    init() throws {
        self.container = try ModelContainer(for: Favorites.self)
        ensureFavoritesExists()
    }
    
    private func ensureFavoritesExists() {
        let context = ModelContext(container)
        let fetchDescriptor = FetchDescriptor<Favorites>(
            predicate: #Predicate { $0.title == "Favorites" }
        )
        
         do {
             let fetchedFavorites = try context.fetch(fetchDescriptor)
             if fetchedFavorites.isEmpty {
                 let favorites = Favorites(id: UUID(), title: "Favorites")
                 context.insert(favorites)
                 try context.save()
             }
         } catch {
             print("Error fetching favorites: \(error)")
         }
    }
}
