//
//  AudioPlayerStore.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/9/24.
//


import Foundation
import Observation
import AVKit
import MediaPlayer

enum PlaybackSource: Equatable {
    case allTracks
    case favorites
    case playlist(UUID)
}

enum PlaybackMode {
    case loopAll
    case loopSingle
    case random

    var systemImageName: String {
        switch self {
        case .loopAll:
            return "repeat"
        case .loopSingle:
            return "repeat.1"
        case .random:
            return "shuffle"
        }
    }
}

@Observable
class AudioPlayerStore: NSObject, AVAudioPlayerDelegate {
    
    @ObservationIgnored private var player: AVAudioPlayer?
    
    var showToast: ShowToastAction?
    var isPlaying = false
    var currentTime: TimeInterval = 0.0
    var totalTime: TimeInterval = 0.0
    var playbackMode: PlaybackMode = .loopAll
    weak var currentTrack: Track?
    var trackList: [Track] = []
    var allTracksProvider: (() -> [Track])?
    var favoritesProvider: (() -> [Favorites])?
    var playlistsProvider: (() -> [Playlist])?
    
    var playbackSource: PlaybackSource = .allTracks {
        didSet {
            updateTrackListFromCurrentSource()
        }
    }
    
    override init() {
        super.init()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            setupRemoteTransportControls()
        } catch {
            showToast?(.error(message: "Audio session setup failed"))
        }
    }
    
    func playTrack(track: Track, playback: PlaybackSource) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(track.fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        guard shouldPlayNewTrack(track, source: playback) else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            totalTime = player?.duration ?? 0.0
            currentTime = 0.0
            currentTrack = track
            playbackSource = playback
        } catch {
            showToast?(.error(message: "Failed to play track"))
        }
        if let track = currentTrack {
            updateNowPlayingInfo(for: track, isPlaying: true)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch playbackMode {
        case .loopSingle:
            if let currentTrack = currentTrack {
                playTrack(track: currentTrack, playback: playbackSource)
            }
        case .random:
            if !trackList.isEmpty {
                let randomTrack = trackList.randomElement()
                if let randomTrack = randomTrack {
                    playTrack(track: randomTrack, playback: playbackSource)
                }
            }
        case .loopAll:
            playNext()
        }
    }

    func playNext() {
        guard currentTrack != nil else {
            clearPlaybackState()
            return
        }
        
        guard let currentIndex = currentTrackIndex else { return }
        
        let nextIndex = currentIndex + 1
        let nextTrack = (nextIndex < trackList.count) ? trackList[nextIndex] : trackList.first
        if let nextTrack = nextTrack {
            playTrack(track: nextTrack, playback: playbackSource)
        }
    }

    func playPrevious() {
        guard currentTrack != nil else {
            clearPlaybackState()
            return
        }
        
        guard let currentIndex = currentTrackIndex else { return }
        
        let prevIndex = currentIndex - 1
        let prevTrack = (prevIndex >= 0) ? trackList[prevIndex] : trackList.last
        if let prevTrack = prevTrack {
            playTrack(track: prevTrack, playback: playbackSource)
        }
    }

    private var currentTrackIndex: Int? {
        guard let currentTrack = currentTrack else { return nil }
        return trackList.firstIndex(of: currentTrack)
    }

    private func shouldPlayNewTrack(_ track: Track, source: PlaybackSource) -> Bool {
        return !(currentTrack == track && source == playbackSource)
    }
    
    func updateTrackListFromCurrentSource() {
        guard let all = allTracksProvider,
              let fav = favoritesProvider,
              let play = playlistsProvider
        else {
            return
        }

        updateTrackList(
            allTracks: all(),
            favorites: fav(),
            playlists: play()
        )
    }

    func updateTrackList(allTracks: [Track], favorites: [Favorites], playlists: [Playlist]) {
        let newList: [Track]
        switch playbackSource {
        case .allTracks:
            newList = allTracks
        case .favorites:
            newList = favorites.first?.trackList ?? []
        case .playlist(let id):
            newList = playlists.first(where: { $0.id == id })?.trackList ?? []
        }
        
        trackList = newList
        
        if newList.isEmpty {
            clearPlaybackState()
        }
    }

    func prepareForTrackDeletion(track: Track, deletedFrom: PlaybackSource) {
        guard track == currentTrack else { return }
        if deletedFrom == playbackSource || deletedFrom == .allTracks {
            playNext()
        }
    }

    func prepareForPlaylistDeletion(playlist: Playlist) {
        if .playlist(playlist.id) == playbackSource {
            clearPlaybackState()
        }
    }

    private func clearPlaybackState() {
        currentTrack = nil
        player?.stop()
        player = nil
        isPlaying = false
        currentTime = 0.0
        totalTime = 0.0
    }
    func cyclePlaybackMode() {
        switch playbackMode {
        case .loopAll:
            playbackMode = .loopSingle
        case .loopSingle:
            playbackMode = .random
        case .random:
            playbackMode = .loopAll
        }
    }

    func stopAudio() {
        player?.pause()
        isPlaying = false
        
        if let track = currentTrack {
            updateNowPlayingInfo(for: track, isPlaying: true)
        }
    }

    func resumeAudio() {
        player?.play()
        isPlaying = true
        
        if let track = currentTrack {
            updateNowPlayingInfo(for: track, isPlaying: true)
        }
    }

    func seekAudio(to time: TimeInterval) {
        player?.currentTime = time
    }

    func updateProgress() {
        currentTime = player?.currentTime ?? 0.0
    }
    
    func updateNowPlayingInfo(for track: Track, isPlaying: Bool) {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: player?.currentTime ?? 0,
            MPMediaItemPropertyPlaybackDuration: player?.duration ?? 0
        ]

        if let artworkImage = UIImage(named: "defaultArtwork") {
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resumeAudio()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.stopAudio()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.playNext()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.playPrevious()
            return .success
        }

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
    }
}
