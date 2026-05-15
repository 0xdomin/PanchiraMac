import SwiftUI
import RealityKit
import AppKit

struct ContentView: View {
    @Environment(AppState.self) private var state

    @State private var characterRoot = Entity()
    @State private var cameraEntity = Entity()
    @State private var dragBaseAzimuth: Float = 0

    private let targetY: Float = 1.0

    var body: some View {
        Group {
            if state.isClamshell {
                clamshellView
            } else {
                mainView
            }
        }
        .frame(minWidth: 600, minHeight: 700)
        .background(Color.black)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NSApp.windows.first?.toggleFullScreen(nil)
            }
        }
    }

    private var clamshellView: some View {
        VStack(spacing: 20) {
            Image(systemName: "macbook")
                .font(.system(size: 72))
                .foregroundStyle(.white.opacity(0.3))
            Text("Not available in clamshell mode")
                .font(.system(.title2, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            Text("Please open your MacBook lid")
                .font(.system(.callout, design: .rounded))
                .foregroundStyle(.white.opacity(0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.06, green: 0.06, blue: 0.1))
    }

    private var mainView: some View {
        ZStack(alignment: .bottom) {
            RealityView { content in
                let character = await loadCharacter()
                characterRoot.name = "characterRoot"
                characterRoot.addChild(character)
                content.add(characterRoot)

                var cam = PerspectiveCameraComponent()
                cam.fieldOfViewInDegrees = 50
                cam.near = 0.1
                cam.far = 100
                cameraEntity.components.set(cam)
                let initialPos = cameraPosition(for: Float(state.angle))
                cameraEntity.position = initialPos
                cameraEntity.look(at: [0, targetY, 0], from: initialPos, relativeTo: nil)
                content.add(cameraEntity)

                for (from, intensity, color) in lights {
                    let light = DirectionalLight()
                    light.light.intensity = intensity
                    light.light.color = color
                    light.look(at: [0, 0, 0], from: from, relativeTo: nil)
                    content.add(light)
                }
            } update: { _ in
                let pos = cameraPosition(for: Float(state.angle))
                cameraEntity.position = pos
                cameraEntity.look(at: [0, targetY, 0], from: pos, relativeTo: nil)
            }
            .background(Color(red: 0.06, green: 0.06, blue: 0.1))
            .gesture(
                DragGesture(minimumDistance: 2)
                    .onChanged { value in
                        state.cameraAzimuth = dragBaseAzimuth + Float(value.translation.width) * 0.008
                    }
                    .onEnded { _ in
                        dragBaseAzimuth = state.cameraAzimuth
                    }
            )
            .onAppear {
                _ = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                    let delta = Float(event.scrollingDeltaY)
                    MainActor.assumeIsolated {
                        state.orbitRadius = max(0.6, min(8.0, state.orbitRadius - delta * 0.04))
                    }
                    return event
                }
            }

            overlayView
        }
    }

    private func cameraPosition(for angle: Float) -> SIMD3<Float> {
        let t = angle / 130.0
        let elevMin: Float = -.pi * 110 / 180
        let elevMax: Float =  .pi * 45 / 180
        let elevation = elevMin + t * (elevMax - elevMin)
        // At angle=0°: r *= 0.75 (25% extra zoom). At 130°: no extra zoom.
        let r = state.orbitRadius * (0.75 + 0.25 * t)
        let az = state.cameraAzimuth
        let y = targetY + r * sin(elevation)
        let xz = r * cos(elevation)
        return [xz * sin(az), y, xz * cos(az)]
    }

    private let lights: [(SIMD3<Float>, Float, NSColor)] = [
        ([1.5,  2.5,  2.0], 2500, NSColor(red: 1.00, green: 0.97, blue: 0.90, alpha: 1)),
        ([-2.0, 1.5,  1.0],  600, NSColor(red: 0.80, green: 0.88, blue: 1.00, alpha: 1)),
        ([0.0,  2.0, -3.0],  400, NSColor(red: 1.00, green: 0.85, blue: 1.00, alpha: 1)),
    ]

    // MARK: - Character

    @MainActor
    private func loadCharacter() async -> Entity {
        if let entity = try? await Entity(named: "character", in: .main) {
            entity.position = [0, 0, 0]
            return entity
        }
        return makePlaceholderCharacter()
    }

    private func makePlaceholderCharacter() -> Entity {
        let root = Entity()

        let skin = NSColor(red: 1.0, green: 0.87, blue: 0.77, alpha: 1)
        let hair = NSColor(red: 0.1,  green: 0.08, blue: 0.18, alpha: 1)
        let blue = NSColor(red: 0.35, green: 0.55, blue: 1.0,  alpha: 1)
        let pink = NSColor.systemPink

        func mat(_ color: NSColor, roughness: Float = 0.7, metallic: Bool = false) -> SimpleMaterial {
            SimpleMaterial(color: color, roughness: .init(floatLiteral: roughness), isMetallic: metallic)
        }

        func add(_ entity: ModelEntity, at pos: SIMD3<Float>) {
            entity.position = pos
            root.addChild(entity)
        }

        // Legs
        for x in [-0.08, 0.08] as [Float] {
            add(ModelEntity(mesh: .generateCylinder(height: 0.55, radius: 0.07), materials: [mat(skin)]),
                at: [x, -0.47, 0])
        }
        // Skirt
        add(ModelEntity(mesh: .generateCylinder(height: 0.38, radius: 0.22), materials: [mat(pink)]),
            at: [0, 0.02, 0])
        // Torso
        add(ModelEntity(mesh: .generateCylinder(height: 0.5, radius: 0.15), materials: [mat(.white)]),
            at: [0, 0.56, 0])
        // Arms
        for x in [-0.27, 0.27] as [Float] {
            let arm = ModelEntity(mesh: .generateCylinder(height: 0.48, radius: 0.065), materials: [mat(skin)])
            arm.position = [x, 0.53, 0]
            arm.transform.rotation = simd_quatf(angle: .pi / 10, axis: [0, 0, x > 0 ? 1 : -1])
            root.addChild(arm)
        }
        // Neck
        add(ModelEntity(mesh: .generateCylinder(height: 0.1, radius: 0.07), materials: [mat(skin)]),
            at: [0, 0.87, 0])
        // Head
        add(ModelEntity(mesh: .generateSphere(radius: 0.21), materials: [mat(skin, roughness: 0.8)]),
            at: [0, 1.14, 0])
        // Hair back
        add(ModelEntity(mesh: .generateSphere(radius: 0.235), materials: [mat(hair, roughness: 0.9)]),
            at: [0, 1.25, -0.01])
        // Hair bang
        add(ModelEntity(mesh: .generateSphere(radius: 0.175), materials: [mat(hair, roughness: 0.9)]),
            at: [0, 1.17, 0.13])
        // Eyes
        for x in [-0.08, 0.08] as [Float] {
            add(ModelEntity(mesh: .generateSphere(radius: 0.043), materials: [mat(blue, roughness: 0.05, metallic: true)]),
                at: [x, 1.13, 0.185])
        }

        root.position = [0, 0.3, 0]
        return root
    }

    // MARK: - Overlay

    private var overlayView: some View {
        HStack(spacing: 16) {
            Label("\(Int(state.angle))°", systemImage: "macbook")
            Spacer()
            Label(String(format: "%.1fx", 2.8 / state.orbitRadius), systemImage: "camera")
            Button(action: pickAndLoadModel) {
                Image(systemName: "folder.badge.plus")
                    .font(.system(.callout, weight: .medium))
            }
            .buttonStyle(.plain)
        }
        .font(.system(.callout, design: .rounded, weight: .medium))
        .foregroundStyle(.white.opacity(0.85))
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    private func pickAndLoadModel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "usdz")!]
        panel.allowsMultipleSelection = false
        panel.title = "Choose a USDZ model"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        Task { @MainActor in
            guard let entity = try? await Entity(contentsOf: url) else { return }
            characterRoot.children.removeAll()
            entity.position = [0, 0, 0]
            characterRoot.addChild(entity)
        }
    }
}
