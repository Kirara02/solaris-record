import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Open large enough for the expanded (rail + two-column) layouts, capped
    // to the screen so it also fits laptop displays.
    let visible = NSScreen.main?.visibleFrame.size ?? NSSize(width: 1440, height: 900)
    let size = NSSize(
      width: min(1360, visible.width * 0.92),
      height: min(860, visible.height * 0.92)
    )
    self.minSize = NSSize(width: 900, height: 620)
    self.setContentSize(size)
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
