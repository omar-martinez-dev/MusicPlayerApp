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
    @Environment(AudioPlayerStore.self) private var audioPlayerStore
    @Environment(FileManagerStore.self) private var fileManagerStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.showToast) private var showToast
    
    @Query private var favorites: [Favorites]
    @State private var showPlaylistSelectionSheet: Bool = false
    @State private var showEditTrackSheet: Bool = false
    @State private var isConfirmingDeletion = false
    
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
                    isConfirmingDeletion = true
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
                .foregroundStyle(.red)
                .confirmationDialog(
                    "Delete \(track.title)?",
                    isPresented: $isConfirmingDeletion,
                    titleVisibility: .visible
                ) {
                    Button("Delete Track", role: .destructive) {
                        if deleteTrack() {
                            dismiss()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This removes the track from your library and deletes its imported audio file.")
                }
            }
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
        saveFavorites()
    }
    
    func removeTrackFromFavorites(track: Track) {
        favorites.first?.removeTrack(track)
        saveFavorites()
    }
    
    private func saveFavorites() {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to update Favorites: \(error.localizedDescription)"))
        }
    }

    func deleteTrack() -> Bool {
        let fileName = track.fileName
        audioPlayerStore.prepareForTrackDeletion(track: track, deletedFrom: .allTracks)
        modelContext.delete(track)

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to delete track: \(error.localizedDescription)"))
            return false
        }

        do {
            try fileManagerStore.deleteFile(withName: fileName)
            showToast(.success(message: "Track deleted successfully"))
        } catch {
            showToast(.error(message: "Track was removed, but its audio file could not be cleaned up"))
        }
        return true
    }
}

//#Preview {
//    TrackOptionsSheet()
//}
