import IOKit
import IOKit.hid
import Foundation
import QuartzCore

@MainActor
final class LidAngleSensor {
    private(set) var angle: Double = 0
    private(set) var angularVelocity: Double = 0
    var onUpdate: (() -> Void)?

    private var device: IOHIDDevice?
    private var timer: Timer?
    private var smoothedAngle: Double = 0
    private var lastAngle: Double = 0
    private var lastTime: Double = 0
    private let smoothingAlpha = 0.1
    private nonisolated static let noOptions = IOOptionBits(kIOHIDOptionsTypeNone)

    var isAvailable: Bool { device != nil }

    func start() {
        device = findDevice()
        guard let device else {
            NSLog("[LidAngleSensor] Device not found — sensor unavailable on this Mac model.")
            return
        }
        // Open fresh — manager was already closed during probe, so this is a clean open.
        guard IOHIDDeviceOpen(device, Self.noOptions) == kIOReturnSuccess else {
            NSLog("[LidAngleSensor] Failed to open device.")
            self.device = nil
            return
        }
        lastTime = CACurrentMediaTime()
        let t = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.poll() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let device {
            IOHIDDeviceClose(device, Self.noOptions)
        }
        device = nil
    }

    // Probe the sensor: open manager with "UsagePage"/"Usage" keys (the correct IOKit
    // registry keys for HID matching), verify a feature report read succeeds, then
    // close the manager via defer. Returns the device reference (device is closed by
    // the manager's defer). start() re-opens it fresh for clean polling access.
    private func findDevice() -> IOHIDDevice? {
        let manager = IOHIDManagerCreate(kCFAllocatorDefault, Self.noOptions)
        guard IOHIDManagerOpen(manager, Self.noOptions) == kIOReturnSuccess else { return nil }
        defer { IOHIDManagerClose(manager, Self.noOptions) }

        let matching: [String: Any] = [
            kIOHIDVendorIDKey as String:  0x05AC,
            kIOHIDProductIDKey as String: 0x8104,
            "UsagePage":                  0x0020,
            "Usage":                      0x008A,
        ]
        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)

        guard let devices = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice>,
              !devices.isEmpty else { return nil }

        for device in devices {
            guard IOHIDDeviceOpen(device, Self.noOptions) == kIOReturnSuccess else { continue }
            defer { IOHIDDeviceClose(device, Self.noOptions) }

            // Verify this device actually provides angle data.
            var report = [UInt8](repeating: 0, count: 8)
            var length = CFIndex(report.count)
            let result = IOHIDDeviceGetReport(device, kIOHIDReportTypeFeature, 1, &report, &length)
            let hex = report[0..<min(Int(length), 8)].map { String(format: "%02X", $0) }.joined(separator: " ")
            NSLog("[LidAngleSensor] probe result=\(result) len=\(length) bytes=[\(hex)]")
            if result == kIOReturnSuccess && length >= 3 {
                let angle = UInt16(report[1]) | UInt16(report[2]) << 8
                NSLog("[LidAngleSensor] Probe OK — angle=\(angle)°")
                return device
            }
        }
        return nil
    }

    private func poll() {
        guard let device else { return }
        var report = [UInt8](repeating: 0, count: 8)
        var length = CFIndex(report.count)
        let result = IOHIDDeviceGetReport(device, kIOHIDReportTypeFeature, 1, &report, &length)
        guard result == kIOReturnSuccess, length >= 3 else { return }

        let raw = Double(UInt16(report[1]) | UInt16(report[2]) << 8)
        smoothedAngle = smoothingAlpha * raw + (1 - smoothingAlpha) * smoothedAngle

        let now = CACurrentMediaTime()
        let dt = now - lastTime
        if dt > 0 {
            let rawVelocity = (smoothedAngle - lastAngle) / dt
            angularVelocity = 0.3 * rawVelocity + 0.7 * angularVelocity
        }
        lastAngle = smoothedAngle
        lastTime = now
        angle = smoothedAngle
        onUpdate?()
    }
}
