import AppKit
import SwiftUI

enum WindowConfigurator {
    /// Turns a standard titled window into a floating, title-less widget (design §8.1, §11).
    @MainActor static func configure(_ window: NSWindow) {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.level = .floating
        window.collectionBehavior.formUnion([.canJoinAllSpaces, .fullScreenAuxiliary])
        // Keep .titled: a window without a title bar can refuse key status, so the composer would stop taking typing (design §15).
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            window.standardWindowButton(button)?.isHidden = true
        }
    }
}

/// Hands the hosting `NSWindow` to `WindowConfigurator` as soon as SwiftUI attaches the view.
struct WindowAccessor: NSViewRepresentable {
    final class ConfiguringView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let window { WindowConfigurator.configure(window) }
        }
    }

    func makeNSView(context: Context) -> ConfiguringView { ConfiguringView() }
    func updateNSView(_ nsView: ConfiguringView, context: Context) {}
}
