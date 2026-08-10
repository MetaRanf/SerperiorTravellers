import SwiftUI

// MARK: - RoundedCard
/// Polished Airbnb-style reusable card
/// Supports image, content, tap, shadows, and generous rounded corners
struct RoundedCard<Content: View>: View {
    var cornerRadius: CGFloat = AppCornerRadius.card
    var shadow: AppShadow = .card
    var borderColor: Color? = nil
    var padding: CGFloat = AppSpacing.cardPadding
    var onTap: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    @State private var isPressed = false

    var body: some View {
        let cardContent = VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            if let borderColor {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            }
        }
        .appShadow(shadow)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppLayout.springBouncy, value: isPressed)

        if let onTap {
            Button {
                onTap()
            } label: {
                cardContent
            }
            .buttonStyle(RoundedCardButtonStyle { pressed in
                isPressed = pressed
            })
        } else {
            cardContent
        }
    }
}

// MARK: - Button Style for press handling
private struct RoundedCardButtonStyle: ButtonStyle {
    var onPressChange: (Bool) -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, new in
                onPressChange(new)
            }
    }
}

// MARK: - Image Card Variant
/// Card with large imagery on top (Airbnb style)
struct ImageRoundedCard<Content: View>: View {
    var image: ImageResourceOrURL
    var cornerRadius: CGFloat = AppCornerRadius.card
    var imageHeight: CGFloat = 200
    var aspectRatio: CGFloat = AppLayout.imageAspectRatio
    var onTap: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        RoundedCard(cornerRadius: cornerRadius, shadow: .card, onTap: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image Section
                ZStack {
                    imageView
                        .aspectRatio(aspectRatio, contentMode: .fill)
                        .frame(height: imageHeight)
                        .clipped()
                }
                // Content Section
                VStack(alignment: .leading, spacing: AppSpacing.s) {
                    content()
                }
                .padding(AppSpacing.cardPadding)
            }
        }
    }

    @ViewBuilder
    private var imageView: some View {
        switch image {
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFill()
        case .system(let sysName):
            Image(systemName: sysName)
                .resizable()
                .scaledToFit()
                .padding(32)
                .foregroundStyle(AppColors.textTertiary)
                .background(AppColors.backgroundSecondary)
        case .url(let urlString):
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(AppColors.shimmerBase)
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(AppColors.backgroundSecondary)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(AppColors.textTertiary)
                        }
                @unknown default:
                    Rectangle().fill(AppColors.shimmerBase)
                }
            }
        case .color(let color):
            color
        }
    }
}

// MARK: - Simple Support Type
enum ImageResourceOrURL {
    case asset(String)
    case system(String)
    case url(String)
    case color(Color)

    static func from(_ string: String) -> Self {
        if string.starts(with: "http") { return .url(string) }
        return .asset(string)
    }
}

// MARK: - Elevated Card Modifier
struct ElevatedCard: View {
    var cornerRadius: CGFloat = AppCornerRadius.card
    var contentPadding: CGFloat = AppSpacing.cardPadding

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppColors.cardBackground)
            .appShadow(.card)
    }
}

// MARK: - RatingBadge helper
struct RatingBadge: View {
    var rating: Double
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill").font(.caption2).foregroundStyle(AppColors.warning)
            Text(String(format: "%.2f", rating)).font(AppTypography.caption1Semibold)
        }
        .padding(.horizontal, 6).padding(.vertical, 3)
        .background(AppColors.cardBackground, in: Capsule())
        .appShadow(.xs)
    }
}

// MARK: - Previews
