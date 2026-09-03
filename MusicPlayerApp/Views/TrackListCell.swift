//
//  TrackListCell.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/16/24.
// <a target="_blank" href="https://icons8.com/icon/1QjKSlRgN3-W/itunes-note">Itunes Note</a> icon by <a target="_blank" href="https://icons8.com">Icons8</a>

import SwiftUI

struct TrackListCell: View {
    
    @Environment(\.audioPlayerStore) var audioPlayerStore
    
    var track: Track
    var optionButtonState: OptionButtonState = .shown
    var playbackSource: PlaybackSource
    var onOptionsTapped: (Track) -> Void = { _ in }
    
    var body: some View {
        HStack {
            TrackIcon(image: track.artwork)
                .overlay {
                    if audioPlayerStore.currentTrack == track && playbackSource == audioPlayerStore.playbackSource {
                        ZStack {
                            if audioPlayerStore.isPlaying {
                                WaveFormView()
                            } else {
                                FlatWaveFormView()
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: audioPlayerStore.isPlaying)
                    }
                }
            
            Button {
                audioPlayerStore.playTrack(track: track, playback: playbackSource)
            } label: {
                TrackBasicInfoView(track: track)
            }
            .buttonStyle(PlainButtonStyle())
            
            
            if optionButtonState == .shown {
                Button {
                    onOptionsTapped(track)
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .padding(.leading, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
    }
}

struct PlainTrackListCell: View {
    
    var track: Track
    
    var body: some View {
        HStack {
            TrackIcon(image: track.artwork)
            TrackBasicInfoView(track: track)
        }
        .frame(maxWidth: .infinity, maxHeight: 50)
    }
}

struct TrackBasicInfoView: View {
    var track: Track
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(track.title)
                .font(.subheadline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack {
                Text(track.artist)
                    .font(.caption)
                
                Spacer()
                
                Label(track.duration.formattedTime, systemImage: "clock")
                    .labelStyle(.titleAndIcon)
                    .font(.caption)
            }
        }
    }
}

enum OptionButtonState {
    case hidden
    case shown
}

enum IconSizes {
    case small
    case medium
    case large
    
    var iconSize: CGFloat {
        switch(self) {
            
        case .small:
            return 50
        case .medium:
            return 120
        case .large:
            return 180
        }
    }
}

struct TrackIcon: View {
    var image: Data?
    var size: IconSizes = .small
    
    var body: some View {
        VStack {
            if let imageData = image {
                ArtworkIcon(imageData: imageData)
            } else {
                MusicNoteIcon()
            }
        }
        .frame(width: size.iconSize, height: size.iconSize)
    }
}

struct MusicNoteIcon: View {
    var body: some View {
        VStack {
            Image(.musicNoteIcon)
                .resizable()
                .scaledToFit()
        }
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.gray.gradient)
        }
    }
}

struct ArtworkIcon: View {
    var imageData: Data
    
    var body: some View {
        if let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            MusicNoteIcon()
        }
    }
}

struct WaveFormView: View {
    @State private var isAnimating: Bool = false
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0 ..< 6) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 3, height: .random(in: isAnimating ? 8...16 : 4...40))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .animation(.easeInOut(duration: 0.25).repeatForever(autoreverses: true), value: isAnimating)
            .onAppear {
                isAnimating.toggle()
            }
        }
    }
}

struct FlatWaveFormView: View {
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0 ..< 6) { _ in
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 3, height: 8)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    @Previewable @State var track: Track = .init(id: UUID(), title: "The Gardens", artist: "Kenneth C M Young, Mat Clark", album: "Little Big Planet", duration: 0.0, fileName: "Unknown", artwork: nil)
    
    VStack(spacing: 20){
        TrackListCell(track: track, playbackSource: .allTracks)
        
        PlainTrackListCell(track: track)
        
        TrackBasicInfoView(track: track)
            .frame(maxWidth: .infinity, maxHeight: 50)
    }
    .padding()
}
