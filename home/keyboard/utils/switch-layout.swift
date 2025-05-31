#!/usr/bin/env swift
// Keyboard layout switcher for macOS
// Uses Text Input Source Services (TIS) APIs from InputMethodKit framework

import Foundation
import InputMethodKit

// MARK: - Types and Models

enum KeyboardLayoutError: Error {
    case layoutNotFound(String)
    case invalidLayoutIndex(Int)
    case noLayoutSpecified
    case invalidArgument(String)
}

struct KeyboardLayout: CustomStringConvertible {
    let source: TISInputSource
    let index: Int
    let name: String
    let id: String
    let isCurrent: Bool
    
    var description: String {
        let marker = isCurrent ? "→ " : "  "
        return "\(marker)\(index): \(name) (\(id))"
    }
}

// MARK: - Keyboard Layout Manager

class KeyboardLayoutManager {
    private let sourceList: NSArray
    private let currentSource: TISInputSource?
    
    init() {
        self.sourceList = TISCreateInputSourceList(nil, false).takeRetainedValue()
        self.currentSource = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue()
    }
    
    func getAllLayouts() -> [KeyboardLayout] {
        var layouts: [KeyboardLayout] = []
        let sourceCount = CFArrayGetCount(sourceList)
        
        for i in 0..<sourceCount {
            guard let sourcePtr = CFArrayGetValueAtIndex(sourceList, i) else { continue }
            let source = unsafeBitCast(sourcePtr, to: TISInputSource.self)
            guard let name = getLocalizedName(source), let id = getInputSourceID(source) else { continue }
            
            // Filter out non-keyboard layouts by checking if the ID contains "com.apple.keylayout"
            if !id.contains("com.apple.keylayout") { continue }
            
            let isCurrent = (currentSource != nil) && (TISGetInputSourceProperty(currentSource!, kTISPropertyLocalizedName) == TISGetInputSourceProperty(source, kTISPropertyLocalizedName))
            let layout = KeyboardLayout(source: source, index: i, name: name, id: id, isCurrent: isCurrent)
            layouts.append(layout)
        }
        return layouts
    }
    
    func getCurrentLayout() -> KeyboardLayout? {
        guard currentSource != nil else { return nil }
        return getAllLayouts().first { $0.isCurrent }
    }
    
    func switchToLayout(_ layout: KeyboardLayout) -> OSStatus {
        return TISSelectInputSource(layout.source)
    }
    
    func findLayout(byName name: String) -> KeyboardLayout? {
        let searchName = name.lowercased()
        return getAllLayouts().first { layout in
            let idParts = layout.id.components(separatedBy: ".")
            guard let lastPart = idParts.last else { return false }
            return lastPart.lowercased() == searchName
        }
    }
    
    func findLayout(byIndex index: Int) -> KeyboardLayout? {
        return getAllLayouts().first { $0.index == index }
    }
    
    // MARK: - Private Helpers
    
    private func getLocalizedName(_ source: TISInputSource) -> String? {
        guard let namePtr = TISGetInputSourceProperty(source, kTISPropertyLocalizedName) else { return nil }
        return unsafeBitCast(namePtr, to: CFString.self) as String?
    }
    
    private func getInputSourceID(_ source: TISInputSource) -> String? {
        guard let idPtr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
        return unsafeBitCast(idPtr, to: CFString.self) as String?
    }
}

// MARK: - CLI Interface

enum Command {
    case list
    case set(layout: String)
    
    static func parse() throws -> Command {
        let args = CommandLine.arguments.dropFirst()
        guard !args.isEmpty else {
            printUsage()
            exit(0)
        }
        
        let command = args.first!
        let remainingArgs = Array(args.dropFirst())
        
        switch command {
        case "list":
            return .list
        case "set":
            guard let layout = remainingArgs.last else {
                throw KeyboardLayoutError.noLayoutSpecified
            }
            return .set(layout: layout)
        default:
            throw KeyboardLayoutError.invalidArgument("Unknown command: \(command)")
        }
    }
    
    static func printUsage() {
        print("""
        Keyboard Layout Switcher
        
        Usage:
          \(CommandLine.arguments[0]) <command> [options]
        
        Commands:
          list                  List all available keyboard layouts
          set <layout>         Set keyboard layout (by index or name)
        
        Examples:
          \(CommandLine.arguments[0]) list
          \(CommandLine.arguments[0]) set 1
          \(CommandLine.arguments[0]) set French
        """)
    }
}

// MARK: - Main Program

do {
    let command = try Command.parse()
    let manager = KeyboardLayoutManager()
    
    switch command {
    case .list:
        print("Available keyboard layouts:")
        for layout in manager.getAllLayouts() {
            print(layout)
        }
    case .set(let layout):
        let targetLayout: KeyboardLayout?
        if let index = Int(layout) {
            targetLayout = manager.findLayout(byIndex: index)
        } else {
            targetLayout = manager.findLayout(byName: layout)
        }
        guard let target = targetLayout else {
            throw KeyboardLayoutError.layoutNotFound("Layout not found: \(layout)")
        }
        let status = manager.switchToLayout(target)
        if status != noErr {
            throw KeyboardLayoutError.layoutNotFound("Failed to switch to layout: \(layout)")
        }
    }
    
} catch KeyboardLayoutError.layoutNotFound(let message) {
    print("Error: \(message)")
    exit(1)
} catch KeyboardLayoutError.invalidLayoutIndex(let index) {
    print("Error: Invalid layout index: \(index)")
    exit(1)
} catch KeyboardLayoutError.noLayoutSpecified {
    print("Error: No layout specified")
    exit(1)
} catch KeyboardLayoutError.invalidArgument(let message) {
    print("Error: \(message)")
    exit(1)
} catch {
    print("Error: \(error)")
    exit(1)
} 