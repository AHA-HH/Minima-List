import AppKit
import Testing
@testable import MinimaList

@MainActor
struct WindowConfiguratorTests {
    @Test func configureMakesAFloatingTitlelessWidget() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: true
        )

        WindowConfigurator.configure(window)

        #expect(window.isOpaque == false)
        #expect(window.backgroundColor == .clear)
        #expect(window.hasShadow)
        #expect(window.isMovableByWindowBackground)
        #expect(window.level == .floating)
        #expect(window.collectionBehavior.contains(.canJoinAllSpaces))
        #expect(window.collectionBehavior.contains(.fullScreenAuxiliary))
        #expect(window.titlebarAppearsTransparent)
        #expect(window.titleVisibility == .hidden)
        #expect(window.styleMask.contains(.fullSizeContentView))
        #expect(window.styleMask.contains(.titled))
        for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            #expect(window.standardWindowButton(button)?.isHidden == true)
        }
    }

    @Test func configureCancelsTheTitleBarSafeArea() throws {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 200),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: true
        )

        WindowConfigurator.configure(window)

        let contentView = try #require(window.contentView)
        let titlebarHeight = window.frame.height - window.contentLayoutRect.height
        #expect(titlebarHeight > 0)
        #expect(contentView.additionalSafeAreaInsets.top == -titlebarHeight)
        #expect(contentView.safeAreaInsets.top == 0)
    }
}
