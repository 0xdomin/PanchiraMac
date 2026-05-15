import Foundation
import Observation
import IOKit

@Observable
@MainActor
final class AppState {
    var angle: Double = 0
    var azimuth: Double = 0
    var cameraAzimuth: Float = 0
    var orbitRadius: Float = 1.8
    var isClamshell: Bool = false

    private let lidSensor = LidAngleSensor()

    init() {
        isClamshell = Self.readClamshellState()
        lidSensor.onUpdate = { [weak self] in
            guard let self else { return }
            self.angle = self.lidSensor.angle
            self.azimuth = self.lidSensor.angle * (360.0 / 130.0)
            self.isClamshell = Self.readClamshellState()
        }
        lidSensor.start()
    }

    private static func readClamshellState() -> Bool {
        guard let matching = IOServiceMatching("IOPMrootDomain") else { return false }
        var iterator = io_iterator_t()
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == kIOReturnSuccess else { return false }
        defer { IOObjectRelease(iterator) }
        let service = IOIteratorNext(iterator)
        guard service != 0 else { return false }
        defer { IOObjectRelease(service) }
        guard let prop = IORegistryEntryCreateCFProperty(service, "AppleClamshellState" as CFString, kCFAllocatorDefault, 0) else { return false }
        return (prop.takeRetainedValue() as? Bool) ?? false
    }
}
