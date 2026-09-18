//
//  TrackEditScreen.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 5/7/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct TrackEditScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.showToast) private var showToast
    
    @State private var titleText: String
    @State private var artistText: String
    @State private var albumText: String
    @State private var artworkData: Data?
    @State private var selectedArtworkItem: PhotosPickerItem?
    var track: Track
    
    init(track: Track) {
        self.track = track
        _titleText = State(initialValue: track.title)
        _artistText = State(initialValue: track.artist)
        _albumText = State(initialValue: track.album)
        _artworkData = State(initialValue: track.artwork)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack {
                        TrackIcon(image: artworkData, title: titleText, artist: artistText, size: .large)
                            .shadow(radius: 8)
                        
                        PhotosPicker(selection: $selectedArtworkItem, matching: .images) {
                            Label("Change Artwork", systemImage: "photo")
                        }
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                        .onChange(of: selectedArtworkItem) { _, newItem in
                            Task {
                                await loadArtwork(from: newItem)
                            }
                        }
                    }
                    
                    VStack(spacing: 16) {
                        EditableField(label: "Title", text: $titleText)
                        EditableField(label: "Artist", text: $artistText)
                        EditableField(label: "Album", text: $albumText)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(radius: 4)
                    
                    Button(action: saveChanges) {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding(32)
                .navigationTitle("Edit Track")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func loadArtwork(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  UIImage(data: data) != nil else {
                showToast(.error(message: "The selected image could not be loaded"))
                return
            }
            artworkData = data
        } catch is CancellationError {
            return
        } catch {
            showToast(.error(message: "Failed to load artwork: \(error.localizedDescription)"))
        }
    }

    private func saveChanges() {
        let title = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        let artist = artistText.trimmingCharacters(in: .whitespacesAndNewlines)
        let album = albumText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !artist.isEmpty, !album.isEmpty else {
            showToast(.error(message: "Title, artist, and album cannot be empty"))
            return
        }

        track.title = title
        track.artist = artist
        track.album = album
        track.artwork = artworkData

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            showToast(.error(message: "Failed to save track: \(error.localizedDescription)"))
        }
    }
}

struct EditableField: View {
    var label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            ZStack(alignment: .trailing) {
                TextField(label, text: $text)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.quaternary)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    }

                if !text.isEmpty {
                    Button(action: {
                        withAnimation {
                            text = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .padding(.trailing, 8)
                            .transition(.opacity)
                    }
                    .accessibilityLabel("Clear \(label)")
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: text)
    }
}

#Preview {
    @Previewable @State var track: Track = .init(id: UUID(), title: "The Gardens", artist: "Kenneth C M Young, Mat Clark", album: "Little Big Planet", duration: 0.0, fileName: "Unknown", artwork: nil)
    
    TrackEditScreen(track: track)
}
