//
//  TrackSelectionView.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 11/28/24.
//

import SwiftUI
import SwiftData

struct TrackSelectionView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var trackList: [Track]
    @State private var multiSelection: Set<UUID> = []
    @State private var editMode: EditMode = .active
    
    var playlist: PlaylistType
    
    var body: some View {
        NavigationStack {
            VStack {
                if !trackList.isEmpty {
                    List(trackList, selection: $multiSelection) { track in
                        PlainTrackListCell(track: track)
                    }
                    .modifier(ListStyle())
                    .environment(\.editMode, $editMode)
                    
                    Text("\(multiSelection.count) Selections")
                } else {
                    ContentUnavailableView("No tracks found", systemImage:  "music.quarternote.3", description: Text("Add some tracks to your library"))
                }
            }
            .navigationTitle("Track Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addTracksToPlaylist()
                    }
                    .disabled(multiSelection.isEmpty)
                }
            }
        }
        .onAppear {
            editMode = .active
        }
    }
    
    func addTracksToPlaylist() {
        let selectedTracks = trackList.filter { multiSelection.contains($0.id) }

        for track in selectedTracks {
            playlist.addTrack(track)
        }

        try? modelContext.save()
        dismiss()
    }
}

//#Preview {
//    TrackSelectionView()
//}

