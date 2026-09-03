//
//  SampleData.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 7/19/25.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    
    static let shared = SampleData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init () {
        let schema = Schema([
            Track.self,
            Playlist.self,
            Favorites.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            insertSampleData()
            
            try context.save()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    private func insertSampleData() {
        for track in Track.sampleData {
            context.insert(track)
        }
        
        for playlist in Playlist.sampleData {
            context.insert(playlist)
        }
        
        for favorite in Favorites.sampleData {
            context.insert(favorite)
        }
    }
}
