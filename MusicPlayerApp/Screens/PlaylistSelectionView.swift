//
//  PlaylistSelectionView.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 11/28/24.
//

import SwiftUI
import SwiftData

struct PlaylistSelectionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.showToast) private var showToast
    @Query(sort: \Playlist.title) private var playlists: [Playlist]
    @Query(sort: \Track.title) private var allTracks: [Track]
    
    var trackSelection: Set<UUID>
    
    @State private var showNewPlaylistAlert = false
    @State private var newPlaylistTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if playlists.isEmpty {
                    ContentUnavailableView(
                        "No Playlists Found",
                        systemImage: "music.note.list",
                        description: Text("Tap the + button to create a new playlist")
                    )
                } else {
                    List(playlists) { playlist in
                        Button {
                            if addTracks(to: playlist) {
                                dismiss()
                            }
                        } label: {
                            PlaylistListCell(playlist: playlist)
                        }
                    }
                    .modifier(ListStyle())
                }
            }
            .navigationTitle("Playlist Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewPlaylistAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create Playlist")
                }
            }
            .alert("New Playlist", isPresented: $showNewPlaylistAlert) {
                TextField("Playlist Title", text: $newPlaylistTitle)
                Button("Create", action: createNewPlaylist)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter a name for your playlist.")
            }
        }
    }
    
    @discardableResult
    func addTracks(to playlist: Playlist) -> Bool {
        let selectedTracks = allTracks.filter { trackSelection.contains($0.id) }
        
        for track in selectedTracks {
            playlist.addTrack(track)
        }

        do {
            try modelContext.save()
            return true
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to add tracks: \(error.localizedDescription)"))
            return false
        }
    }
    
    func createNewPlaylist() {
        let trimmedTitle = newPlaylistTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let titleExists = playlists.contains { $0.title.lowercased() == trimmedTitle.lowercased() }
        guard !titleExists else {
            showToast(.error(message: "Playlist title must be unique"))
            return
        }
        
        let newPlaylist = Playlist(id: UUID(), title: trimmedTitle)
        modelContext.insert(newPlaylist)
        let selectedTracks = allTracks.filter { trackSelection.contains($0.id) }
        for track in selectedTracks {
            newPlaylist.addTrack(track)
        }

        do {
            try modelContext.save()
            newPlaylistTitle = ""
            dismiss()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to create playlist: \(error.localizedDescription)"))
        }
    }
}

#Preview {
    @Previewable var trackList: Set<UUID> = [UUID()]
    PlaylistSelectionView(trackSelection: trackList)
        .modelContainer(SampleData.shared.modelContainer)
        .withToast()
}
