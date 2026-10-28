import Testing
@testable import MinimaList

struct MotionTests {
    @Test func toggleSpringsOnlyWithoutReduceMotion() {
        #expect(Motion.toggle(reduceMotion: true) == nil)
        #expect(Motion.toggle(reduceMotion: false) != nil)
    }

    @Test(arguments: [false, true])
    func hoverAlwaysFades(reduceMotion: Bool) {
        #expect(Motion.hover(reduceMotion: reduceMotion) != nil)
    }

    @Test func removalSoftensWithReduceMotion() {
        let normal = Motion.removal(reduceMotion: false)
        let reduced = Motion.removal(reduceMotion: true)
        #expect(normal != nil)
        #expect(reduced != nil)
        #expect(normal != reduced)
    }
}
