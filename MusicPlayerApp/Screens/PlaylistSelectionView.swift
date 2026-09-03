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
    @Query private var playlists: [Playlist]
    @Query private var allTracks: [Track]
    
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
                            addTracks(to: playlist)
                            dismiss()
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
    
    func addTracks(to playlist: Playlist) {
        let selectedTracks = allTracks.filter { trackSelection.contains($0.id) }
        
        for track in selectedTracks {
            if !playlist.trackList.contains(track) {
                playlist.trackList.append(track)
            }
        }
        
        try? modelContext.save()
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
        try? modelContext.save()
        newPlaylistTitle = ""
    }
}

#Preview {
    @Previewable var trackList: Set<UUID> = [UUID()]
    PlaylistSelectionView(trackSelection: trackList)
        .modelContainer(SampleData.shared.modelContainer)
        .withToast()
}
