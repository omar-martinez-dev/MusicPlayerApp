//
//  TracksScreen.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/16/24.
//

import SwiftUI
import SwiftData

struct TracksScreen: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.fileManagerStore) private var fileManagerStore
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @Environment(\.showToast) private var showToast
    
    @Query private var trackList: [Track]
    @State private var searchText = ""
    @State private var isImporting: Bool = false
    @State private var showSheet: Bool = false
    @State private var selectedTrack: Track? = nil
    @State private var multiTrackSelection: Set<UUID> = []
    @State private var editMode: EditMode = .inactive
    
    var filteredTracks: [Track] {
        if searchText.isEmpty {
            return trackList
        } else {
            return trackList.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if editMode.isEditing {
                    List(trackList, selection: $multiTrackSelection) { track in
                        TrackListCell(track: track, optionButtonState: .hidden , playbackSource: .allTracks)
                    }
                    .modifier(ListStyle())
                    .environment(\.editMode, $editMode)
                    .searchable(text: $searchText, prompt: "Search")
                } else {
                    List {
                        ForEach(filteredTracks) { track in
                            TrackListCell(
                                track: track,
                                playbackSource: .allTracks) { selectedTrack in
                                    self.selectedTrack = selectedTrack
                                }
                        }
                        .onDelete(perform: deleteTrack)
                    }
                    .modifier(ListStyle())
                    .environment(\.editMode, $editMode)
                    .searchable(text: $searchText, prompt: "Search")
                }
            }
            .if(audioPlayerStore.currentTrack != nil) { view in
                view.modifier(MiniMusicPlayerModifier())
            }
            .navigationTitle("Tracks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        toggleEditMode()
                    } label: {
                        Image(systemName: editMode.isEditing ? "checkmark.square.fill" : "checkmark.square")
                    }
                    .disabled(trackList.isEmpty)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        audioPlayerStore.cyclePlaybackMode()
                    } label: {
                        Image(systemName: audioPlayerStore.playbackMode.systemImageName)
                    }
                    .disabled(trackList.isEmpty ||  editMode.isEditing)
                    .opacity(editMode.isEditing ? 0 : 1)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if editMode.isEditing {
                            showSheet.toggle()
                            toggleEditMode()
                        } else {
                            isImporting.toggle()
                        }
                    } label: {
                        Image(systemName: editMode.isEditing ? "music.note.list" : "plus.app")
                            .disabled(editMode.isEditing && multiTrackSelection.isEmpty)
                    }
                }
            }
            .overlay {
                if (trackList.isEmpty) {
                    ContentUnavailableView("No tracks found", systemImage:  "music.quarternote.3", description: Text("Add some tracks to your library"))
                }
            }
            .sheet(isPresented: $showSheet) {
                PlaylistSelectionView(trackSelection: multiTrackSelection)
            }
            .sheet(item: $selectedTrack) { track in
                TrackOptionsSheet(track: track)
                    .presentationDetents([.fraction(0.40)])
                    .withToast()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.mp3, .wav],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let URLs):
                    Task {
                        for fileURL in URLs {
                            if let track = await importData(url: fileURL) {
                                saveTrack(track: track)
                                showToast(.success(message: "Track(s) imported successfully"))
                            }
                        }
                    }
                case .failure(let error):
                    showToast(.error(message: "Failed to import file: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    func importData(url: URL) async -> Track? {
        guard url.startAccessingSecurityScopedResource() else { return nil }
        defer { url.stopAccessingSecurityScopedResource() }
        
        return await fileManagerStore.saveImportedFile(url)
    }
    
    func saveTrack(track: Track?) {
        if let track = track {
            modelContext.insert(track)
            try? modelContext.save()
        }
    }
    
    func deleteTrack(at Offsets: IndexSet) {
        for offset in Offsets {
            let track = trackList[offset]
            audioPlayerStore.prepareForTrackDeletion(track: track, deletedFrom: .allTracks)
            fileManagerStore.deleteFile(withName: track.fileName)
            
            modelContext.delete(track)
            try? modelContext.save()
            
            showToast(.success(message: "Track(s) deleted successfully"))
        }
    }
    
    func toggleEditMode() {
        if editMode == .inactive {
            editMode = .active
            multiTrackSelection = []
        } else {
            editMode = .inactive
        }
    }
}
    

#Preview {
    TracksScreen()
        .modelContainer(SampleData.shared.modelContainer)
        .withToast()
}
