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
        // No minimize button is shown, so a title-bar double-click (under the "Minimize" setting) must not send the widget to the Dock.
        window.styleMask.remove(.miniaturizable)
        for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            window.standardWindowButton(button)?.isHidden = true
        }
        // The hidden title bar still gives the content view a top safe-area inset (its height, computed here at runtime;
        // 32 pt on the dev machine), and SwiftUI grows a
        // .contentSize window by it, leaving an invisible strip above the widget. Cancel it so the window is the content's size.
        let titlebarHeight = window.frame.height - window.contentLayoutRect.height
        window.contentView?.additionalSafeAreaInsets = NSEdgeInsets(top: -titlebarHeight, left: 0, bottom: 0, right: 0)
    }

    /// A titled window draws its own rounded-square border and shadow around the count bubble (design §8.7). The bubble never
    /// takes typing, so it drops `.titled` while collapsed; expanding restores it so the composer can become key again.
    @MainActor static func setCollapsed(_ collapsed: Bool, _ window: NSWindow) {
        guard collapsed == window.styleMask.contains(.titled) else { return }
        if collapsed {
            window.styleMask.remove(.titled)
        } else {
            window.styleMask.insert(.titled)
            configure(window)
        }
        window.invalidateShadow()
    }
}

/// Hands the hosting `NSWindow` to `WindowConfigurator` as soon as SwiftUI attaches the view.
struct WindowAccessor: NSViewRepresentable {
    var isCollapsed = false

    final class ConfiguringView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let window { WindowConfigurator.configure(window) }
        }
    }

    func makeNSView(context: Context) -> ConfiguringView { ConfiguringView() }
    func updateNSView(_ nsView: ConfiguringView, context: Context) {
        if let window = nsView.window { WindowConfigurator.setCollapsed(isCollapsed, window) }
    }
}
