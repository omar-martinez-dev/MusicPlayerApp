//
//  TrackEditScreen.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 5/7/25.
//

import SwiftUI

struct TrackEditScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.showToast) private var showToast
    
    @State private var titleText: String
    @State private var artistText: String
    @State private var albumText: String
    var track: Track
    
    init(track: Track) {
        self.track = track
        _titleText = State(initialValue: track.title)
        _artistText = State(initialValue: track.artist)
        _albumText = State(initialValue: track.album)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack {
                        TrackIcon(image: track.artwork, size: .large)
                            .shadow(radius: 8)
                        
                        Button("Change Artwork") {
                            // Future image picker logic
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    }
                    
                    VStack(spacing: 16) {
                        EditableField(label: "Title", text: $titleText)
                        EditableField(label: "Artist", text: $artistText)
                        EditableField(label: "Album", text: $albumText)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 4)
                    
                    Button {
                        track.title = titleText
                        track.artist = artistText
                        track.album = albumText
                        
                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            showToast(.error(message: "Failed to save track: \(error)"))
                        }
                    } label: {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
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
}

struct EditableField: View {
    var label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack(alignment: .trailing) {
                TextField(label, text: $text)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemGroupedBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )

                if !text.isEmpty {
                    Button(action: {
                        withAnimation {
                            text = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(.trailing, 8)
                            .transition(.opacity)
                    }
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
