import SwiftUI

// MARK: - AppSpacing
/// Generous Airbnb-like spacing scale - 4pt base
enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let sm: CGFloat = 12
    static let m: CGFloat = 16
    static let ml: CGFloat = 20
    static let l: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 56
    static let huge: CGFloat = 80

    // Semantic spacing
    static let cardPadding: CGFloat = 16
    static let screenHorizontal: CGFloat = 24
    static let screenVertical: CGFloat = 20
    static let sectionSpacing: CGFloat = 32
    static let itemSpacing: CGFloat = 12
    static let groupSpacing: CGFloat = 16
}

// MARK: - Corner Radius
/// Rounded corners - Airbnb uses 12-24 for cards, 32 for pills
enum AppCornerRadius {
    static let xs: CGFloat = 4
    static let s: CGFloat = 8
    static let m: CGFloat = 12
    static let l: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let full: CGFloat = 9999

    // Semantic
    static let card: CGFloat = 16
    static let cardLarge: CGFloat = 24
    static let button: CGFloat = 12
    static let buttonPill: CGFloat = 9999
    static let image: CGFloat = 12
    static let imageLarge: CGFloat = 16
    static let sheet: CGFloat = 24
    static let badge: CGFloat = 8
    static let badgePill: CGFloat = 9999
}

// MARK: - Shadows
/// Soft, diffused shadows like Airbnb
struct AppShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    // Factory presets
    static let none = AppShadow(color: .clear, radius: 0, x: 0, y: 0)
    static let xs = AppShadow(color: AppColors.shadow, radius: 4, x: 0, y: 1)
    static let s = AppShadow(color: AppColors.shadow, radius: 8, x: 0, y: 2)
    static let m = AppShadow(color: AppColors.shadow, radius: 12, x: 0, y: 4)
    static let l = AppShadow(color: AppColors.shadowMedium, radius: 20, x: 0, y: 8)
    static let xl = AppShadow(color: AppColors.shadowMedium, radius: 32, x: 0, y: 12)
    static let card = AppShadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 4)
    static let cardHover = AppShadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 8)
    static let floating = AppShadow(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 12)
}

// MARK: - Shadow View Modifier
struct ShadowModifier: ViewModifier {
    let shadow: AppShadow
    func body(content: Content) -> some View {
        content.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func appShadow(_ shadow: AppShadow = .m) -> some View {
        modifier(ShadowModifier(shadow: shadow))
    }
    func cardShadow() -> some View {
        modifier(ShadowModifier(shadow: .card))
    }
}

// MARK: - AppLayout
/// Global layout constants
enum AppLayout {
    // Screen
    static let maxContentWidth: CGFloat = 672
    static let maxCardWidth: CGFloat = 400

    // Cards
    static let cardHeightSmall: CGFloat = 160
    static let cardHeightMedium: CGFloat = 220
    static let cardHeightLarge: CGFloat = 300
    static let imageAspectRatio: CGFloat = 4.0 / 3.0
    static let propertyCardAspect: CGFloat = 1.0 // Square images for properties
    static let activityCardAspect: CGFloat = 4.0 / 5.0 // Portrait for activities

    // Buttons
    static let buttonHeightSmall: CGFloat = 36
    static let buttonHeightMedium: CGFloat = 44
    static let buttonHeightLarge: CGFloat = 56
    static let buttonMinWidth: CGFloat = 120

    // Search
    static let searchBarHeight: CGFloat = 56
    static let searchBarCornerRadius: CGFloat = 32

    // List
    static let listRowHeight: CGFloat = 72
    static let iconSizeSmall: CGFloat = 16
    static let iconSizeMedium: CGFloat = 20
    static let iconSizeLarge: CGFloat = 24
    static let iconSizeXLarge: CGFloat = 32

    // Carousel
    static let carouselSpacing: CGFloat = 12
    static let carouselPeek: CGFloat = 24

    // Grid
    static let gridColumns: Int = 2
    static let gridSpacing: CGFloat = 16

    // Animation
    static let animationFast: Double = 0.2
    static let animationMedium: Double = 0.3
    static let animationSlow: Double = 0.5
    static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let springSmooth = Animation.spring(response: 0.5, dampingFraction: 0.9)
}

// MARK: - Edge Insets helpers
extension EdgeInsets {
    static let screen = EdgeInsets(
        top: AppSpacing.screenVertical,
        leading: AppSpacing.screenHorizontal,
        bottom: AppSpacing.screenVertical,
        trailing: AppSpacing.screenHorizontal
    )
    static let card = EdgeInsets(
        top: AppSpacing.cardPadding,
        leading: AppSpacing.cardPadding,
        bottom: AppSpacing.cardPadding,
        trailing: AppSpacing.cardPadding
    )
}
