import Foundation
import Testing
@testable import MusicPlayerApp

struct TimeIntervalTests {
    @Test(
        "Formats playback time as minutes and seconds",
        arguments: [
            (value: 0.0, expected: "00:00"),
            (value: 65.0, expected: "01:05"),
            (value: 3_599.0, expected: "59:59")
        ]
    )
    func formatsPlaybackTime(value: TimeInterval, expected: String) {
        #expect(value.formattedTime == expected)
    }
}
