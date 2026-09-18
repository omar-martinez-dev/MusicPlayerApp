//
//  PlaylistScreen.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/16/24.
//

import SwiftUI
import SwiftData

struct PlaylistScreen: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AudioPlayerStore.self) private var audioPlayerStore
    @Environment(\.showToast) private var showToast
    
    @Query(sort: \Playlist.title) private var playlists: [Playlist]
    @Query private var favorites: [Favorites]
    @State private var searchText: String = ""
    @State private var playlistTitleTextField: String = ""
    @State private var showingAlert: Bool = false
    
    var filteredPlaylist: [Playlist] {
        if searchText.isEmpty {
            return playlists
        } else {
            return playlists.filter {
                $0.title.localizedStandardContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Favorites")) {
                        if let favorites = favorites.first {
                            NavigationLink(destination: PlaylistTrackListScreen(playlist: favorites, playbackSource: .favorites)) {
                                PlaylistListCell(playlist: favorites)
                            }
                        } else {
                            ContentUnavailableView(
                                "Favorites Unavailable",
                                systemImage: "heart.slash",
                                description: Text("The Favorites collection could not be loaded.")
                            )
                        }
                    }
                    
                    Section(header: Text("Playlists")) {
                        ForEach(filteredPlaylist) { playlist in
                            NavigationLink(destination: PlaylistTrackListScreen(playlist: playlist, playbackSource: .playlist(playlist.id))) {
                                PlaylistListCell(playlist: playlist)
                            }
                        }
                        .onDelete(perform: deletePlaylist)
                    }
                }
                .if(audioPlayerStore.currentTrack != nil) { view in
                    view.modifier(MiniMusicPlayerModifier())
                }
                .alert("Create Playlist", isPresented: $showingAlert) {
                               TextField("Enter playlist name", text: $playlistTitleTextField)
                               
                               Button("Create") {
                                   createPlaylist(playlistName: playlistTitleTextField)
                               }
                               
                               Button("Cancel", role: .cancel) {
                                   playlistTitleTextField = ""
                               }
                           } message: {
                               Text("Please enter a name for your new playlist.")
                           }
                .modifier(ListStyle())
                .searchable(text: $searchText, prompt: "Search")
                .overlay {
                    if playlists.isEmpty && favorites.isEmpty {
                        ContentUnavailableView("No Playlists", systemImage: "music.note.list", description: Text("Add some playlists to get started."))
                    }
                }
            }
            .navigationTitle("Playlists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        audioPlayerStore.cyclePlaybackMode()
                    } label: {
                        Image(systemName: audioPlayerStore.playbackMode.systemImageName)
                    }
                    .accessibilityLabel("Change Playback Mode")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create Playlist")
                }
            }
        }
    }
    
    func createPlaylist(playlistName: String) {
        let trimmedName = playlistName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        guard !playlists.contains(where: { $0.title.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame }) else {
            showToast(.error(message: "Playlist names must be unique"))
            return
        }
        
        let newPlaylist = Playlist(id: UUID(), title: trimmedName)
        modelContext.insert(newPlaylist)
        do {
            try modelContext.save()
            playlistTitleTextField = ""
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to create playlist: \(error.localizedDescription)"))
        }
    }
    
    func deletePlaylist(at offsets: IndexSet) {
        let playlistsToDelete = offsets.compactMap { index in
            filteredPlaylist.indices.contains(index) ? filteredPlaylist[index] : nil
        }

        for playlist in playlistsToDelete {
            audioPlayerStore.prepareForPlaylistDeletion(playlist: playlist)
            modelContext.delete(playlist)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to delete playlist: \(error.localizedDescription)"))
        }
    }
}

#Preview {
    PlaylistScreen()
        .modelContainer(SampleData.shared.modelContainer)
        .environment(AudioPlayerStore())
        .withToast()
}
