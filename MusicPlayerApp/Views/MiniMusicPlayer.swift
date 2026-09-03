//
//  MiniMusicPlayer.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/25/24.
//

import SwiftUI

struct MiniMusicPlayer: View {
    
    @Environment(\.audioPlayerStore) private var audioPlayerStore
    @State private var showMusicPlayer: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            Button {
                showMusicPlayer.toggle()
            } label: {
                HStack(alignment: .center){
                    TrackIcon(image: audioPlayerStore.currentTrack?.artwork ?? nil)
                        .overlay {
                            ZStack {
                                if audioPlayerStore.isPlaying {
                                    WaveFormView()
                                } else {
                                    FlatWaveFormView()
                                }
                            }
                            .animation(.easeInOut(duration: 0.3), value: audioPlayerStore.isPlaying)
                        }
                    
                    VStack (alignment: .leading) {
                        Text(audioPlayerStore.currentTrack?.title ?? "No Track Selected")
                            .font(.callout)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .buttonStyle(.plain)
            
            Button {
                audioPlayerStore.isPlaying ? audioPlayerStore.stopAudio() : audioPlayerStore.resumeAudio()
            } label: {
                Image(systemName: audioPlayerStore.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            
            Button {
                audioPlayerStore.playNext()
            } label: {
                Image(systemName: "forward.end.fill")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, maxHeight: 60)
        .background(Color(UIColor.systemBackground))
        .fullScreenCover(isPresented: $showMusicPlayer) {
            MusicPlayer()
        }
    }
}

struct MiniMusicPlayerModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                MiniMusicPlayer()
                    .frame(maxWidth: .infinity, maxHeight: 60)
                
            }
    }
}

#Preview {
    MiniMusicPlayer()
}
