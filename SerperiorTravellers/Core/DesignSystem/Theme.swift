import SwiftUI

// MARK: - AppTheme
/// Central theme object bundling all design tokens
/// Airbnb-inspired, supports light/dark via semantic colors
struct AppTheme {
    // Tokens
    let colors = AppColors.self
    let spacing = AppSpacing.self
    let cornerRadius = AppCornerRadius.self

    // Light / Dark
    var colorScheme: ColorScheme = .light

    // Shared instance for previews
    static let light = AppTheme(colorScheme: .light)
    static let dark = AppTheme(colorScheme: .dark)
    static let current = AppTheme(colorScheme: .light)

    // Helpers
    var isDark: Bool { colorScheme == .dark }
}

// MARK: - Theme Environment
private struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.current
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Theme ViewModifiers
struct ThemedBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .background(AppColors.background)
            .colorScheme(colorScheme)
    }
}

struct CardBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat = AppCornerRadius.card
    var shadow: AppShadow = .card
    func body(content: Content) -> some View {
        content
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .appShadow(shadow)
    }
}

struct ThemedCardModifier: ViewModifier {
    var padding: CGFloat = AppSpacing.cardPadding
    var cornerRadius: CGFloat = AppCornerRadius.card
    var shadow: AppShadow = .card

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .appShadow(shadow)
    }
}

// MARK: - Convenience Extensions
extension View {
    func appThemedBackground() -> some View {
        modifier(ThemedBackground())
    }

    func themedCard(padding: CGFloat = AppSpacing.cardPadding,
                    cornerRadius: CGFloat = AppCornerRadius.card,
                    shadow: AppShadow = .card) -> some View {
        modifier(ThemedCardModifier(padding: padding, cornerRadius: cornerRadius, shadow: shadow))
    }

    func cardBackground(cornerRadius: CGFloat = AppCornerRadius.card,
                        shadow: AppShadow = .card) -> some View {
        modifier(CardBackgroundModifier(cornerRadius: cornerRadius, shadow: shadow))
    }

    /// Inject theme into environment
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
}

// MARK: - Global App Appearance Helper
// Black scene bug (Image 1-5): status bar area and home-indicator area black because window background black.
// Good Structure attempted UIView.appearance white (forced white) which fixed black bars but blanked images (after-fix3).
// Good UI looks nicer because it uses plain system TabView + systemBackground, no UIKit overrides except minimal,
// and relies on SwiftUI backgrounds ignoringSafeArea.
// Final fix matching Good UI: only set UIWindow to white + override light, set TabBar opaque via system colors,
// DO NOT set UIView.appearance globally (that blanks AsyncImage/search pill). Keep nav bars default SwiftUI.
enum AppAppearance {
    static func configure() {
        // Window white – kills black top/bottom seen in Image 1,2,3. Good UI uses light.
        UIWindow.appearance().backgroundColor = UIColor.white

        // TabBar opaque secondarySystemBackground (light gray/white) – fixes iOS 26 floating blur capsule
        // overlapping cards seen in first screenshot (blur pill covering Bali card).
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.white
        tabAppearance.shadowColor = UIColor.black.withAlphaComponent(0.08)
        tabAppearance.shadowImage = nil
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

// MARK: - Preview Helpers
struct ThemePreviewContainer<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        Group {
            content.appTheme(.light).preferredColorScheme(.light)
            content.appTheme(.dark).preferredColorScheme(.dark)
        }
    }
}
