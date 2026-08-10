import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let visibleFrame = NSScreen.main?.visibleFrame ?? self.frame
    let width = min(1680.0, visibleFrame.width * 0.92)
    let height = min(1050.0, visibleFrame.height * 0.88)
    let windowFrame = NSRect(
      x: visibleFrame.midX - width / 2,
      y: visibleFrame.midY - height / 2,
      width: width,
      height: height
    )
    self.contentViewController = flutterViewController
    self.minSize = NSSize(width: 1200, height: 760)
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
