//
//  PlaylistTrackListScreen.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 10/16/24.
//

import Foundation
import SwiftUI

struct PlaylistTrackListScreen: View {
    
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @Environment(\.modelContext) private var modelContext
    
    @State private var searchText: String = ""
    @State private var showAddTrackSheet: Bool = false
    var playlist: PlaylistType
    var playbackSource: PlaybackSource
    
    var body: some View {
        VStack {
            List {
                ForEach(playlist.trackList) { track in
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
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAddTrackSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
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
        audioPlayerStore.prepareForTrackDeletion(track: playlist.trackList[Offsets.first!], deletedFrom: playbackSource)
        playlist.trackList.remove(atOffsets: Offsets)
        try? modelContext.save()
    }
}
