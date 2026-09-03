//
//  TrackOptionsSheet.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 10/27/24.
//

import Foundation
import SwiftUI
import SwiftData

struct TrackOptionsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @Environment(\.fileManagerStore) private var fileManagerStore
    @Environment(\.dismiss) private var dismiss
    
    @Query private var playlists: [Playlist]
    @Query private var favorites: [Favorites]
    @State private var showPlaylistSelectionSheet: Bool = false
    @State private var showEditTrackSheet: Bool = false
    
    var track: Track
    var trackSet: Set<UUID> {
        [track.id]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PlainTrackListCell(track: track)
            }
            .padding()
            
            List {
                Button {
                    if track.favorite {
                        removeTrackFromFavorites(track: track)
                    } else {
                        addTrackToFavorites(track: track)
                    }
                } label: {
                    Label(track.favorite ? "Remove from favorites" : "Add to favorites", systemImage: track.favorite ? "heart.fill" : "heart")
                }
                
                Button {
                    showPlaylistSelectionSheet.toggle()
                } label: {
                    Label("Add to playlist", systemImage: "music.note.list")
                }
                
                Button {
                    showEditTrackSheet.toggle()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button {
                    deleteTrack()
                    dismiss()
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
            }
            .buttonStyle(.plain)
            .scrollContentBackground(.hidden)
            .contentMargins(.vertical, 0)
        }
        .sheet(isPresented: $showPlaylistSelectionSheet) {
            PlaylistSelectionView(trackSelection: trackSet)
        }
        .sheet(isPresented: $showEditTrackSheet) {
            TrackEditScreen(track: track)
        }
    }
    
    func addTrackToFavorites(track: Track) {
        favorites.first?.addTrack(track)
    }
    
    func removeTrackFromFavorites(track: Track) {
        favorites.first?.removeTrack(track)
    }
    
    func deleteTrack() {
        audioPlayerStore.prepareForTrackDeletion(track: track, deletedFrom: .allTracks)
        fileManagerStore.deleteFile(withName: track.fileName)
        
        modelContext.delete(track)
        try? modelContext.save()
    }
}

//#Preview {
//    TrackOptionsSheet()
//}
