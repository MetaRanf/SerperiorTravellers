import SwiftUI

@main
public struct SerperiorTravellersApp: App {
    @StateObject private var dependencies = DependencyContainer(configuration: .current, latency: .zero)
    @StateObject private var appState = AppState()

    public init() {
        // Good UI looks nicer because it doesn't mess with UIKit appearance.
        // We keep AppAppearance minimal but ensure window background white (not black)
        AppAppearance.configure()
    }

    public var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(dependencies)
                .environment(\.dependencies, dependencies)
                .tint(AppColors.primary)
                // Fix black scene: force background white that ignores all safe areas, matching Good UI light polish
                .background(Color.white.ignoresSafeArea())
                .background(Color(uiColor: .systemBackground).ignoresSafeArea())
                .preferredColorScheme(.light)
                .task {
                    await dependencies.seedIfNeeded()
                }
                .onAppear {
                    // Extra safety: explicitly paint UIWindow white in light, kills black top/bottom (Image 1,2,3)
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        scene.windows.forEach { win in
                            win.backgroundColor = UIColor.white
                            win.overrideUserInterfaceStyle = .light
                        }
                    }
                }
        }
    }
}
