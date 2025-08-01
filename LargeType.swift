import Cocoa
import Foundation

let version = "dev" // to be replaced with actual version in the build script

func printUsage() {
    print("""
LargeType - Display text in large font fullscreen overlay

Usage:
  largetype <text> [options]

Options:
  --font-family <sans-serif|monospace|system|CustomFontName>   Font type (default: sans-serif)
  --font-size <number>                Font size in points (default: 72)
  --font-weight <ultralight|thin|light|regular|medium|semibold|bold|heavy|black>   Font weight (default: regular)
  --background-color <rrggbbaa>       Background color in hex (default: 00000080)
  --color <rrggbb>                    Text color in hex (default: ffffff)
  --text-align <left|center|right>    Text alignment (default: center)
  --padding <number[px|%]>            Padding around text (default: 5%)
  --hide-after <seconds>              Hide overlay after N seconds
  --help                              Show this help message
  --version                           Show version

Examples:
  largetype "Hello World"
  largetype "Code" --font-family monospace --color 00ff00 --background-color 000000ff
  largetype "Big" --font-size 120 --font-weight bold --text-align left --padding 10%
  largetype "Timed" --hide-after 3
""")
}

struct CLIArgs {
var text: String
var font: NSFont
var backgroundColor: NSColor
var textColor: NSColor
var showHelp: Bool
var showVersion: Bool
var fixedFontSize: Bool
var textAlign: NSTextAlignment
var padding: Padding
var hideAfter: Double?
struct Padding {
    enum Unit { case px, percent }
    var value: CGFloat
    var unit: Unit
}

    static func parse(_ args: [String]) -> CLIArgs {
        var fontType = "sans-serif"
        var fontSize: CGFloat = 72
        var fontWeight: NSFont.Weight = .medium
        var backgroundColorString = "00000080"
        var textColorString = "ffffff"
        var showHelp = false
        var showVersion = false
        var textArgs: [String] = []
        var fixedFontSize = false
        var textAlign: NSTextAlignment = .center
        var padding = Padding(value: 5, unit: .percent)
        var hideAfter: Double? = nil
        var i = 1
        while i < args.count {
            let arg = args[i]
            if arg == "--font-size" && i + 1 < args.count {
                if let size = Double(args[i + 1]) { fontSize = CGFloat(size); fixedFontSize = true }
                i += 2
            } else if arg == "--font-weight" && i + 1 < args.count {
                fontWeight = parseWeight(args[i + 1])
                i += 2
            } else if arg == "--font-family" && i + 1 < args.count {
                fontType = args[i + 1]
                i += 2
            } else if arg == "--background-color" && i + 1 < args.count {
                backgroundColorString = args[i + 1]
                i += 2
            } else if arg == "--color" && i + 1 < args.count {
                textColorString = args[i + 1]
                i += 2
            } else if arg == "--text-align" && i + 1 < args.count {
                let align = args[i + 1].lowercased()
                switch align {
                case "left": textAlign = .left
                case "right": textAlign = .right
                default: textAlign = .center
                }
                i += 2
            } else if arg == "--padding" && i + 1 < args.count {
                let padStr = args[i + 1].trimmingCharacters(in: .whitespaces)
                if padStr.hasSuffix("px") {
                    if let val = Double(padStr.dropLast(2)) {
                        padding = Padding(value: CGFloat(val), unit: .px)
                    }
                } else if padStr.hasSuffix("%") {
                    if let val = Double(padStr.dropLast()) {
                        padding = Padding(value: CGFloat(val), unit: .percent)
                    }
                } else if let val = Double(padStr) {
                    padding = Padding(value: CGFloat(val), unit: .px)
                }
                i += 2
            } else if arg == "--hide-after" && i + 1 < args.count {
                if let val = Double(args[i + 1]) {
                    hideAfter = val
                }
                i += 2
            } else if arg == "--help" {
                showHelp = true
                i += 1
            } else if arg == "--version" {
                showVersion = true
                i += 1
            } else if !arg.hasPrefix("--") {
                textArgs.append(arg)
                i += 1
            } else {
                i += 1
            }
        }
        let text = textArgs.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        let font = parseFont(name: fontType, size: fontSize, weight: fontWeight)
        let backgroundColor = parseColor(backgroundColorString)
        let textColor = parseColor(textColorString)
        
        return CLIArgs(
            text: text,
            font: font,
            backgroundColor: backgroundColor,
            textColor: textColor,
            showHelp: showHelp,
            showVersion: showVersion,
            fixedFontSize: fixedFontSize,
            textAlign: textAlign,
            padding: padding,
            hideAfter: hideAfter
        )
    }
}

// Parse font name, size, and weight
func parseFont(name: String, size: CGFloat, weight: NSFont.Weight) -> NSFont {
    switch name.lowercased() {
    case "monospace":
        return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
    case "sans-serif":
        return NSFont.systemFont(ofSize: size, weight: weight)
    case "system":
        return NSFont.systemFont(ofSize: size, weight: weight)
    default:
        if let customFont = NSFont(name: name, size: size) {
            return customFont
        } else {
            print("Error: Font '", name, "' not found. Use a valid font name.")
            exit(1)
        }
    }
}

func parseWeight(_ w: String) -> NSFont.Weight {
    switch w.lowercased() {
    case "ultralight": return .ultraLight
    case "thin": return .thin
    case "light": return .light
    case "regular": return .regular
    case "medium": return .medium
    case "semibold": return .semibold
    case "bold": return .bold
    case "heavy": return .heavy
    case "black": return .black
    default: return .regular
    }
}

func parseColor(_ hexString: String) -> NSColor {
    var hex = hexString
    if hex.hasPrefix("#") {
        hex = String(hex.dropFirst())
    }
    if hex.count == 8 {
        var rgba: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgba)
        let alpha = CGFloat(rgba & 0x000000FF) / 255.0
        rgba = rgba >> 8
        let r = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgba & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgba & 0x0000FF) / 255.0
        return NSColor(red: r, green: g, blue: b, alpha: alpha)
    } else if hex.count == 6 {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    } else {
        return NSColor.black.withAlphaComponent(0.5)
    }
}

class LargeTypeWindow: NSWindow {
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}

class LargeTypeView: NSView {
    var text: String = ""
    var textColor: NSColor = NSColor.white
    var backgroundColor: NSColor = NSColor.black.withAlphaComponent(0.5)
    var font: NSFont = NSFont.systemFont(ofSize: 72)
    var fixedFontSize: Bool = false
    var textAlign: NSTextAlignment = .center
    var padding: CLIArgs.Padding = CLIArgs.Padding(value: 60, unit: .px)
    
    override func draw(_ dirtyRect: NSRect) {
        // Fill background
        backgroundColor.setFill()
        dirtyRect.fill()

        let maxFontSize = calculateMaxFontSize(for: text, in: bounds)
        let finalFontSize = fixedFontSize ? min(font.pointSize, maxFontSize) : maxFontSize
        let adjustedFont = font.withSize(finalFontSize)

        // Create paragraph style for center alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlign

        // Text attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: adjustedFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        // Calculate text rect for centering
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedString.size()
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )

        // Draw the text
        attributedString.draw(in: textRect)
    }
    
    func calculateMaxFontSize(for text: String, in rect: NSRect) -> CGFloat {
        let availableWidth: CGFloat
        let availableHeight: CGFloat
        let verticalPadding: CGFloat = 60
        switch padding.unit {
        case .px:
            availableWidth = rect.width - (2 * padding.value)
        case .percent:
            availableWidth = rect.width - (rect.width * (padding.value / 100.0) * 2)
        }
        availableHeight = rect.height - (2 * verticalPadding)
        
        var fontSize: CGFloat = 12
        var maxFontSize: CGFloat = 12
        
        // Binary search for the largest font size that fits
        var low: CGFloat = 12
        var high: CGFloat = min(availableWidth, availableHeight)
        
        while high - low > 1 {
            fontSize = (low + high) / 2
            let testFont = font.withSize(fontSize)
            let size = text.size(withAttributes: [.font: testFont])
            
            if size.width <= availableWidth && size.height <= availableHeight {
                maxFontSize = fontSize
                low = fontSize
            } else {
                high = fontSize
            }
        }
        
        return max(maxFontSize, 12) // Minimum font size of 12
    }
    
    override func mouseDown(with event: NSEvent) {
        NSApp.terminate(nil)
    }
    
    override var acceptsFirstResponder: Bool { return true }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape key
            NSApp.terminate(nil)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: LargeTypeWindow?
    var largeTypeView: LargeTypeView?
    let args: CLIArgs

    init(args: CLIArgs) {
        self.args = args
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Get screen dimensions
        guard let screen = NSScreen.main else {
            print("Error: Could not get main screen")
            exit(1)
        }

        let screenFrame = screen.frame

        // Create window
        window = LargeTypeWindow(
            contentRect: screenFrame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window?.isOpaque = false
        window?.backgroundColor = NSColor.clear
        window?.level = NSWindow.Level.screenSaver
        window?.ignoresMouseEvents = false
        window?.acceptsMouseMovedEvents = true

        // Create and configure the view
        largeTypeView = LargeTypeView(frame: screenFrame)
        largeTypeView?.text = args.text
        largeTypeView?.textColor = args.textColor
        largeTypeView?.backgroundColor = args.backgroundColor
        largeTypeView?.font = args.font
        largeTypeView?.fixedFontSize = args.fixedFontSize
        largeTypeView?.textAlign = args.textAlign
        largeTypeView?.padding = args.padding

        window?.contentView = largeTypeView
        window?.makeKeyAndOrderFront(nil)
        window?.makeFirstResponder(largeTypeView)

        // Make app active
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        // Hide after N seconds if requested
        if let hideAfter = args.hideAfter, hideAfter > 0 {
            Timer.scheduledTimer(withTimeInterval: hideAfter, repeats: false) { _ in
                NSApp.terminate(nil)
            }
        }
    }
    
    // ...existing code...
}

let args = CLIArgs.parse(CommandLine.arguments)
if args.showHelp {
    printUsage()
    exit(0)
}
if args.showVersion {
    print("largetype version: \(version)")
    exit(0)
}
if args.text.isEmpty {
    print("Error: No text provided.\n")
    printUsage()
    exit(1)
}

let app = NSApplication.shared
let delegate = AppDelegate(args: args)
app.delegate = delegate

// Set up global event monitor for escape key
var globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 53 { // Escape key
        NSApp.terminate(nil)
    }
}

// Prevent app from terminating when window closes
app.setActivationPolicy(.regular)

// Run the app
app.run()

// Cleanup
if let monitor = globalEventMonitor {
    NSEvent.removeMonitor(monitor)
}
