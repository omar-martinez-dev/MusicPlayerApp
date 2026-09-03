//
//  MusicPlayer.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/13/24.
//

import SwiftUI
import SwiftData

struct MusicPlayer: View {
    
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @Environment(\.dismiss) private var dismiss
    @Query private var favorites: [Favorites]
    
    @State private var isDraggingSlider: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                ZStack {
                    Rectangle()
                        .fill(.ultraThickMaterial)
                        .overlay {
                            Rectangle()
                            if let artworkData = audioPlayerStore.currentTrack?.artwork,
                               let uiImage = UIImage(data: artworkData) {
                                Image(uiImage: uiImage)
                                    .blur(radius: 55)
                            } else {
                                Rectangle()
                                    .fill(Color(UIColor.systemBackground).gradient)
                            }
                                
                        }
                    
                    VStack(spacing: 15) {
                        
                        GeometryReader {
                            let imageSize = $0.size
                            
                            if let artworkData = audioPlayerStore.currentTrack?.artwork,
                               let uiImage = UIImage(data: artworkData) {
                                // If artwork exists, display it
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize.width, height: imageSize.width)
                                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                            } else {
                                // If no artwork, show a placeholder
                                Rectangle()
                                    .fill(Color(UIColor.systemGray3).gradient)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize.width, height: imageSize.width)
                                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                    .overlay(alignment: .center) {
                                        Image(.musicNoteIcon)
                                            .resizable()
                                            .scaledToFit()
                                    }
                            }
                        }
                        .frame(height: size.width)
                        .padding(.top, size.height < 700 ? 10 : 30)
                        
                        GeometryReader {
                            
                            let size = $0.size
                            
                            VStack {
                                
                                HStack(alignment: .center, spacing: 15) {
                                    VStack(alignment: .leading, spacing: 4){
                                        Text(audioPlayerStore.currentTrack?.title ?? "No Title")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        
                                        Text(audioPlayerStore.currentTrack?.artist ?? "Unknown Artist")
                                            .foregroundStyle(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Button {
                                        if let track = audioPlayerStore.currentTrack {
                                            if track.favorite {
                                                removeTrackFromFavorites(track: track)
                                            } else {
                                                addTrackToFavorites(track: track)
                                            }
                                        }
                                    } label: {
                                        if let track = audioPlayerStore.currentTrack {
                                            Image(systemName: track.favorite ? "heart.fill" : "heart")
                                                .foregroundStyle(.white)
                                                .padding(12)
                                        }
                                    }
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: {
                                            audioPlayerStore.currentTime
                                        },
                                        set: { newValue in
                                            audioPlayerStore.currentTime = newValue
                                            if !isDraggingSlider {
                                                audioPlayerStore.seekAudio(to: newValue)
                                            }
                                        }
                                    ),
                                    in: 0...audioPlayerStore.totalTime
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { _ in
                                            isDraggingSlider = true
                                        }
                                        .onEnded { _ in
                                            isDraggingSlider = false
                                            audioPlayerStore.seekAudio(to: audioPlayerStore.currentTime)
                                        }
                                )
                                .foregroundStyle(.white)
                                .buttonStyle(.plain)
                                
                                HStack {
                                    Text(audioPlayerStore.currentTime.formattedTime)
                                    Spacer()
                                    Text(audioPlayerStore.totalTime.formattedTime)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: size.width * 0.18) {
                                    Button {
                                        audioPlayerStore.playPrevious()
                                    } label: {
                                        Image(systemName: "backward.fill")
                                            .modifier(PlayerIconButtonFont(size: size))
                                    }
                                    
                                    Button {
                                        audioPlayerStore.isPlaying ? audioPlayerStore.stopAudio() : audioPlayerStore.resumeAudio()
                                    } label: {
                                        Image(systemName: audioPlayerStore.isPlaying ? "pause.fill" : "play.fill")
                                            .font(size.height < 300 ? .largeTitle : .system(size: 50))
                                    }
                                    
                                    Button {
                                        audioPlayerStore.playNext()
                                    } label: {
                                        Image(systemName: "forward.fill")
                                            .modifier(PlayerIconButtonFont(size: size))
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, safeArea.top + (safeArea.bottom == 0 ? 10 : 0))
                    .padding(.bottom, safeArea.bottom == 0 ? 10 : safeArea.bottom)
                    .padding(.horizontal, 25)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .clipped()
                      
                }
                .ignoresSafeArea(.container, edges: .all)
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
            .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect(), perform: { _ in
                audioPlayerStore.updateProgress()
            })
        }
    }
    
    func addTrackToFavorites(track: Track) {
        favorites.first?.addTrack(track)
    }
    
    func removeTrackFromFavorites(track: Track) {
        favorites.first?.removeTrack(track)
    }
}

struct PlayerIconButtonFont: ViewModifier {
    
    var size: CGSize
    
    func body(content: Content) -> some View {
        content
            .font(size.height < 300 ? .title3 : .title)
    }
}

#Preview {
    MusicPlayer()
}
