//
//  PlaylistTrackListScreen.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 10/16/24.
//

import Foundation
import SwiftUI
import SwiftData

struct PlaylistTrackListScreen: View {
    
    @Environment(AudioPlayerStore.self) private var audioPlayerStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.showToast) private var showToast
    
    @State private var searchText: String = ""
    @State private var showAddTrackSheet: Bool = false
    var playlist: PlaylistType
    var playbackSource: PlaybackSource

    private var filteredTracks: [Track] {
        guard !searchText.isEmpty else { return playlist.trackList }
        return playlist.trackList.filter { $0.title.localizedStandardContains(searchText) }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(filteredTracks) { track in
                    TrackListCell(track: track, optionButtonState: .hidden, playbackSource: playbackSource)
                }
                .onDelete(perform: deleteTrack)
            }
            .modifier(ListStyle())
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            
        }
        .navigationTitle(playlist.title)
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
                    showAddTrackSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Tracks")
            }
        }
        .if(audioPlayerStore.currentTrack != nil) { view in
            view.modifier(MiniMusicPlayerModifier())
        }
        .sheet(isPresented: $showAddTrackSheet) {
            TrackSelectionView(playlist: playlist)
        }
        .overlay {
            if (playlist.trackList.isEmpty) {
                ContentUnavailableView("No tracks found", systemImage:  "music.quarternote.3", description: Text("Add some tracks to your library"))
            }
        }
    }
    
    func deleteTrack(at Offsets: IndexSet) {
        let tracksToRemove = Offsets.compactMap { index in
            filteredTracks.indices.contains(index) ? filteredTracks[index] : nil
        }

        for track in tracksToRemove {
            audioPlayerStore.prepareForTrackDeletion(track: track, deletedFrom: playbackSource)
            playlist.removeTrack(track)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to update playlist: \(error.localizedDescription)"))
        }
    }
}
