import Foundation
import SwiftData
@testable import MusicPlayerApp

enum TestFactory {
    @MainActor
    static func makeContainer() throws -> ModelContainer {
        try StartUpStore.makeContainer(isStoredInMemoryOnly: true)
    }

    static func makeTrack(
        title: String = "Test Track",
        fileName: String = "test.mp3"
    ) -> Track {
        Track(
            id: UUID(),
            title: title,
            artist: "Test Artist",
            album: "Test Album",
            duration: 180,
            fileName: fileName
        )
    }
}
