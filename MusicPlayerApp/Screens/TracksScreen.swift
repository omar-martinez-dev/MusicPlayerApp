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
    @Environment(FileManagerStore.self) private var fileManagerStore
    @Environment(AudioPlayerStore.self) private var audioPlayerStore
    @Environment(\.showToast) private var showToast
    
    @Query(sort: \Track.title) private var trackList: [Track]
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
                $0.title.localizedStandardContains(searchText)
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
                ToolbarItem(placement: .topBarLeading) {
                    Button(
                        editMode.isEditing ? "Finish Selecting" : "Select Tracks",
                        systemImage: editMode.isEditing ? "checkmark.square.fill" : "checkmark.square",
                        action: toggleEditMode
                    )
                    .labelStyle(.iconOnly)
                    .disabled(trackList.isEmpty)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        audioPlayerStore.cyclePlaybackMode()
                    } label: {
                        Image(systemName: audioPlayerStore.playbackMode.systemImageName)
                    }
                    .accessibilityLabel("Change Playback Mode")
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
                    }
                    .accessibilityLabel(editMode.isEditing ? "Add Selection to Playlist" : "Import Tracks")
                    .disabled(editMode.isEditing && multiTrackSelection.isEmpty)
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
                    .presentationDetents([.medium, .large])
                    .withToast()
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.mp3, .wav],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    Task {
                        await importTracks(from: urls)
                    }
                case .failure(let error):
                    showToast(.error(message: "Failed to import file: \(error.localizedDescription)"))
                }
            }
        }
    }
    
    func importTracks(from urls: [URL]) async {
        var importedCount = 0

        for url in urls {
            do {
                let track = try await fileManagerStore.importTrack(from: url)
                modelContext.insert(track)

                do {
                    try modelContext.save()
                    importedCount += 1
                } catch {
                    modelContext.rollback()
                    try? fileManagerStore.deleteFile(withName: track.fileName)
                    throw error
                }
            } catch is CancellationError {
                return
            } catch {
                showToast(.error(message: "Failed to import \(url.lastPathComponent): \(error.localizedDescription)"))
            }
        }

        if importedCount > 0 {
            showToast(.success(message: "Imported \(importedCount) track(s) successfully"))
        }
    }
    
    func deleteTrack(at Offsets: IndexSet) {
        let tracksToDelete = Offsets.compactMap { index in
            filteredTracks.indices.contains(index) ? filteredTracks[index] : nil
        }
        let fileNamesToDelete = tracksToDelete.map(\.fileName)

        for track in tracksToDelete {
            audioPlayerStore.prepareForTrackDeletion(track: track, deletedFrom: .allTracks)
            modelContext.delete(track)
        }

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to delete tracks: \(error.localizedDescription)"))
            return
        }

        var cleanupErrors = 0
        for fileName in fileNamesToDelete {
            do {
                try fileManagerStore.deleteFile(withName: fileName)
            } catch {
                cleanupErrors += 1
            }
        }

        if cleanupErrors == 0 {
            showToast(.success(message: "Track(s) deleted successfully"))
        } else {
            showToast(.error(message: "Tracks were removed, but \(cleanupErrors) audio file(s) could not be cleaned up"))
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
        .environment(AudioPlayerStore())
        .environment(FileManagerStore())
        .withToast()
}
