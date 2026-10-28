import SwiftUI

// Design §9 and §12: every animation lives here so the Reduce Motion rules are tested in one place.
enum Motion {
    static func toggle(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(duration: 0.3)
    }

    // A fade isn't motion, so Reduce Motion keeps it.
    static func hover(reduceMotion: Bool) -> Animation? {
        .easeInOut(duration: 0.15)
    }

    static func removal(reduceMotion: Bool) -> Animation? {
        reduceMotion ? .linear(duration: 0.15) : .easeOut(duration: 0.2)
    }

    static func rowTransition(reduceMotion: Bool) -> AnyTransition {
        reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .trailing))
    }
}
