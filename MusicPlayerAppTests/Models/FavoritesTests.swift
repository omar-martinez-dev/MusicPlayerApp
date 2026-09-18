import Foundation
import Testing
@testable import MusicPlayerApp

struct FavoritesTests {
    @Test("Adding a track marks it as favorite without duplicating it")
    func addingFavoriteUpdatesTrack() {
        let favorites = Favorites(id: UUID(), title: "Favorites")
        let track = TestFactory.makeTrack()

        favorites.addTrack(track)
        favorites.addTrack(track)

        #expect(track.favorite)
        #expect(favorites.trackList.count == 1)
    }

    @Test("Removing a track clears its favorite state")
    func removingFavoriteUpdatesTrack() {
        let favorites = Favorites(id: UUID(), title: "Favorites")
        let track = TestFactory.makeTrack()
        favorites.addTrack(track)

        favorites.removeTrack(track)

        #expect(track.favorite == false)
        #expect(favorites.trackList.isEmpty)
    }
}
