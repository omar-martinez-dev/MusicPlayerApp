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
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @Environment(\.showToast) private var showToast
    
    @Query private var playlists: [Playlist]
    @Query private var favorites: [Favorites]
    @State private var searchText: String = ""
    @State private var playlistTitleTextField: String = ""
    @State private var showingAlert: Bool = false
    
    var filteredPlaylist: [Playlist] {
        if searchText.isEmpty {
            return playlists
        } else {
            return playlists.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Favorites")) {
                        NavigationLink(destination: PlaylistTrackListScreen(playlist: favorites.first!, playbackSource: .favorites)) {
                            PlaylistListCell(playlist: favorites.first!)
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
                                   print("Playlist creation cancelled")
                               }
                           } message: {
                               Text("Please enter a name for your new playlist.")
                           }
                .modifier(ListStyle())
                .searchable(text: $searchText, prompt: "Search")
                .overlay {
                    if (playlists.isEmpty) {
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
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAlert.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    func createPlaylist(playlistName: String) {
        guard !playlistName.isEmpty else { return }
        guard !playlists.contains(where: { $0.title == playlistName }) else { return }
        
        let newPlaylist = Playlist(id: UUID(), title: playlistName)
        modelContext.insert(newPlaylist)
        try? modelContext.save()
    }
    
    func deletePlaylist(at offsets: IndexSet) {
            offsets.forEach { index in
                let playlist = playlists[index]
                modelContext.delete(playlist)
            }
            try? modelContext.save()
        }
}

#Preview {
    PlaylistScreen()
        .modelContainer(SampleData.shared.modelContainer)
}
