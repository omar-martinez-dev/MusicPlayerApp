import Foundation
import Testing
@testable import MusicPlayerApp

struct PlaylistTests {
    @Test("Adding the same track twice does not create duplicates")
    func addingDuplicateTrackIsIgnored() {
        let playlist = Playlist(id: UUID(), title: "Road Trip")
        let track = TestFactory.makeTrack()

        playlist.addTrack(track)
        playlist.addTrack(track)

        #expect(playlist.trackList.count == 1)
        #expect(playlist.trackList.first?.id == track.id)
    }

    @Test("Removing a track leaves other tracks in place")
    func removingTrackPreservesOtherTracks() {
        let playlist = Playlist(id: UUID(), title: "Road Trip")
        let firstTrack = TestFactory.makeTrack(title: "First")
        let secondTrack = TestFactory.makeTrack(title: "Second")
        playlist.addTrack(firstTrack)
        playlist.addTrack(secondTrack)

        playlist.removeTrack(firstTrack)

        #expect(playlist.trackList.map(\.id) == [secondTrack.id])
    }
}
