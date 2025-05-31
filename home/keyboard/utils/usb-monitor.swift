#!/usr/bin/env swift

import Foundation
import IOKit
import IOKit.usb
import IOKit.hid

// ANSI color codes
private enum ANSI {
    static let RESET = "\u{001B}[0m"
    static let RED = "\u{001B}[31m"
    static let GREEN = "\u{001B}[32m"
    static let YELLOW = "\u{001B}[33m"
    static let BLUE = "\u{001B}[34m"
    static func red(_ text: Any) -> String {
        return "\(RED)\(text)\(RESET)"
    }
    static func green(_ text: Any) -> String {
        return "\(GREEN)\(text)\(RESET)"
    }
    static func yellow(_ text: Any) -> String {
        return "\(YELLOW)\(text)\(RESET)"
    }
    static func blue(_ text: Any) -> String {
        return "\(BLUE)\(text)\(RESET)"
    }
}

class USBMonitor {
    private var hidManager: IOHIDManager?
    private let targetProductId: Int?
    private let targetManufacturer: String?
    private let onConnectCommand: String?
    private let onDisconnectCommand: String?

    init(targetProductId: Int? = nil, targetManufacturer: String? = nil, onConnectCommand: String? = nil, onDisconnectCommand: String? = nil) {
        self.targetProductId = targetProductId
        self.targetManufacturer = targetManufacturer
        self.onConnectCommand = onConnectCommand
        self.onDisconnectCommand = onDisconnectCommand

        // Create HID Manager
        hidManager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))

        guard let manager = hidManager else {
            print("Failed to create HID Manager")
            return
        }

        // Set up matching dictionary for keyboards
        let keyboardMatching = [
            kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
            kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
        ] as CFDictionary

        // Set the matching dictionary
        IOHIDManagerSetDeviceMatching(manager, keyboardMatching)

        // Set up callbacks
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, result, sender, device in
            let monitor = Unmanaged<USBMonitor>.fromOpaque(context!).takeUnretainedValue()
            monitor.deviceAdded(device)
        }, context)

        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, result, sender, device in
            let monitor = Unmanaged<USBMonitor>.fromOpaque(context!).takeUnretainedValue()
            monitor.deviceRemoved(device)
        }, context)

        // Schedule with run loop
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)

        // Open the HID Manager
        let openResult = IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        if openResult != kIOReturnSuccess {
            print("Failed to open HID Manager: \(openResult)")
            if openResult == kIOReturnNotPrivileged {
                print("Permission denied. Please check System Preferences > Security & Privacy > Privacy > Input Monitoring")
            }
        }
    }

    private func shouldFilterDevice(_ device: IOHIDDevice) -> Bool {
        // Check product ID filter
        if let targetId = targetProductId,
           let productId = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int,
           productId != targetId {
            return true
        }

        // Check manufacturer filter
        if let targetManu = targetManufacturer,
           let manufacturer = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String,
           manufacturer.lowercased() != targetManu.lowercased() {
            return true
        }

        return false
    }

    private func executeCommand(_ command: String) {
        let task = Process()
        let pipe = Pipe()

        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["-c", command]
        task.standardOutput = pipe
        task.standardError = pipe

        print(ANSI.blue("┌─ Command Output"))
        print("\(ANSI.blue("│")) Executing: \(ANSI.green("`\(command)`"))")
        print(ANSI.blue("├─"))

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if !output.isEmpty {
                    // Split output into lines and format each line
                    let lines = output.components(separatedBy: .newlines)
                    for line in lines {
                        print("\(ANSI.blue("│")) \(line)")
                    }
                }
            }

            if task.terminationStatus != 0 {
                print(ANSI.blue("├─"))
                print("\(ANSI.blue("│")) \(ANSI.yellow("Command exited with status \(task.terminationStatus)"))")
            }
            print(ANSI.blue("└─"))
        } catch {
            print(ANSI.blue("├─"))
            print("\(ANSI.blue("│")) \(ANSI.yellow("Failed to execute command: \(error.localizedDescription)"))")
            print(ANSI.blue("└─"))
        }
    }

    private func deviceAdded(_ device: IOHIDDevice) {
        let deviceInfo = getDeviceInfo(device)

        // Check if we should filter this device
        if shouldFilterDevice(device) {
            return
        }

        print(ANSI.blue("┌─ Device Connected"))
        // Split device info into lines and format each line
        let lines = deviceInfo.components(separatedBy: .newlines)
        for line in lines {
            print("\(ANSI.blue("│")) \(ANSI.green(line))")
        }
        print(ANSI.blue("└─"))

        // Execute the on-connect command if specified
        if let command = onConnectCommand {
            executeCommand(command)
        }
    }

    private func deviceRemoved(_ device: IOHIDDevice) {
        let deviceInfo = getDeviceInfo(device)

        // Check if we should filter this device
        if shouldFilterDevice(device) {
            return
        }

        print(ANSI.blue("┌─ Device Disconnected"))
        // Split device info into lines and format each line
        let lines = deviceInfo.components(separatedBy: .newlines)
        for line in lines {
            print("\(ANSI.blue("│")) \(ANSI.red(line))")
        }
        print(ANSI.blue("└─"))

        // Execute the on-disconnect command if specified
        if let command = onDisconnectCommand {
            executeCommand(command)
        }
    }

    private func getDeviceInfo(_ device: IOHIDDevice) -> String {
        var info = [String]()

        if let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String {
            info.append("Name: \(name)")
        }
        if let manufacturer = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String {
            info.append("Manufacturer: \(manufacturer)")
        }
        if let vendorID = IOHIDDeviceGetProperty(device, kIOHIDVendorIDKey as CFString) as? Int {
            info.append("Vendor ID: \(vendorID)")
        }
        if let productID = IOHIDDeviceGetProperty(device, kIOHIDProductIDKey as CFString) as? Int {
            info.append("Product ID: \(productID)")
        }

        return info.joined(separator: "\n")
    }
}

// Parse command line arguments
var targetProductId: Int? = nil
var targetManufacturer: String? = nil
var onConnectCommand: String? = nil
var onDisconnectCommand: String? = nil
var args = CommandLine.arguments.dropFirst() // Skip the program name

while !args.isEmpty {
    let arg = args.removeFirst()
    switch arg {
    case "--productId":
        if args.isEmpty {
            print("Error: Missing product ID value")
            exit(1)
        }
        if let pid = Int(args.removeFirst()) {
            targetProductId = pid
        } else {
            print("Error: Invalid product ID format")
            exit(1)
        }
    case "--manufacturer":
        if args.isEmpty {
            print("Error: Missing manufacturer value")
            exit(1)
        }
        targetManufacturer = args.removeFirst()
    case "--on-connect":
        if args.isEmpty {
            print("Error: Missing command value")
            exit(1)
        }
        onConnectCommand = args.removeFirst()
    case "--on-disconnect":
        if args.isEmpty {
            print("Error: Missing command value")
            exit(1)
        }
        onDisconnectCommand = args.removeFirst()
    default:
        print("Error: Unknown argument '\(arg)'")
        print("Usage: \(CommandLine.arguments[0]) [--productId <id>] [--manufacturer <name>] [--on-connect \"<command>\"] [--on-disconnect \"<command>\"]")
        exit(1)
    }
}

// Create a global monitor instance with the filters and commands
let globalMonitor = USBMonitor(
    targetProductId: targetProductId,
    targetManufacturer: targetManufacturer,
    onConnectCommand: onConnectCommand,
    onDisconnectCommand: onDisconnectCommand
)

print("Starting USB monitor...")
if let pid = targetProductId {
    print("Filtering for product ID: \(ANSI.green(pid))")
}
if let manu = targetManufacturer {
    print("Filtering for manufacturer: \(ANSI.green(manu))")
}
if let cmd = onConnectCommand {
    print("Will execute on disconnect: \(ANSI.green(cmd))")
}
if let cmd = onDisconnectCommand {
    print("Will execute on disconnect: \(ANSI.green(cmd))")
}
if targetProductId == nil && targetManufacturer == nil {
    print("No filters applied - showing all USB events")
}
print("Press Ctrl+C to stop\n")

// Keep the program running
RunLoop.main.run()
