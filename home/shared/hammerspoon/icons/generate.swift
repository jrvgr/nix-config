// Regenerates brightness.png from the real "sun.max" SF Symbol via AppKit,
// padded onto a 2x canvas so it's crisp and not edge-to-edge in the menu bar.
// Run with: swift generate.swift
import AppKit

func exportPaddedSymbol(name: String, canvasPx: CGFloat, glyphPt: CGFloat, outPath: String) {
    let config = NSImage.SymbolConfiguration(pointSize: glyphPt, weight: .regular, scale: .medium)
    guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else {
        fputs("failed to load symbol \(name)\n", stderr)
        exit(1)
    }
    symbol.isTemplate = true

    let canvas = NSImage(size: NSSize(width: canvasPx, height: canvasPx))
    canvas.isTemplate = true
    canvas.lockFocus()
    let glyphSize = symbol.size
    let x = (canvasPx - glyphSize.width) / 2
    let y = (canvasPx - glyphSize.height) / 2
    symbol.draw(at: NSPoint(x: x, y: y), from: .zero, operation: .sourceOver, fraction: 1.0)
    canvas.unlockFocus()

    guard let tiff = canvas.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let pngData = rep.representation(using: .png, properties: [:]) else {
        fputs("failed to render png\n", stderr)
        exit(1)
    }
    try! pngData.write(to: URL(fileURLWithPath: outPath))
    print("wrote \(outPath) canvas=\(canvasPx) glyphPt=\(glyphPt)")
}

let scriptDir = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path
exportPaddedSymbol(
    name: "sun.max",
    canvasPx: 36, // 2x pixel backing for an 18pt logical menu bar icon
    glyphPt: 24, // smaller than the canvas so the glyph has a bit of padding
    outPath: scriptDir + "/brightness.png"
)
