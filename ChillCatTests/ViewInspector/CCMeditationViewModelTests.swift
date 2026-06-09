import XCTest
@testable import ChillCat

final class CCMeditationViewModelTests_V2: XCTestCase {

    func test_meditationPresets_hasCorrectCount() {
        XCTAssertEqual(CCMeditationSession.presets.count, 3)
    }

    func test_meditationCategories_valid() {
        let categories = CCMeditationSession.presets.map(\.category)
        XCTAssertTrue(categories.contains(.sleep))
        XCTAssertTrue(categories.contains(.relax))
        XCTAssertTrue(categories.contains(.anxiety))
    }

    func test_presets_haveValidAudioURLs() {
        for preset in CCMeditationSession.presets {
            XCTAssertFalse(preset.audioURL.absoluteString.isEmpty)
        }
    }
}
