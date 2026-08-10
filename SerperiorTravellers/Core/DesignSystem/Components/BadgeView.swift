import SwiftUI

enum BadgeStyle: Equatable {
    case hot
    case trending
    case superhost
    case category
    case neutral
    case success
    case warning
    case price
    case newBadge

    var backgroundColor: Color {
        switch self {
        case .hot: return AppColors.hotBadgeBackground
        case .trending: return AppColors.trendingBadgeBackground
        case .superhost: return AppColors.cardBackground
        case .category: return AppColors.categoryBadgeBackground
        case .neutral: return AppColors.backgroundSecondary
        case .success: return Color.green.opacity(0.15)
        case .warning: return Color.orange.opacity(0.15)
        case .price: return AppColors.cardBackground
        case .newBadge: return AppColors.primary
        }
    }

    var textColor: Color {
        switch self {
        case .hot: return AppColors.hotBadgeText
        case .trending: return AppColors.trendingBadgeText
        case .superhost: return AppColors.textPrimary
        case .category: return AppColors.textPrimary
        case .neutral: return AppColors.textSecondary
        case .success: return Color.green
        case .warning: return Color.orange
        case .price: return AppColors.textPrimary
        case .newBadge: return .white
        }
    }
}

struct BadgeView: View {
    let text: String
    var style: BadgeStyle = .neutral
    var isPill: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            if style == .hot {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10, weight: .semibold))
            }
            Text(text)
                .font(AppTypography.caption1Bold)
                .lineLimit(1)
        }
        .foregroundStyle(style.textColor)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(style.backgroundColor)
        .clipShape(Capsule())
        .overlay {
            if style == .superhost || style == .category {
                Capsule().stroke(AppColors.borderLight, lineWidth: 1)
            }
        }
    }
}

struct HotBadge: View {
    var text: String = "HOT"
    var body: some View { BadgeView(text: text, style: .hot) }
}
struct TrendingBadge: View {
    var text: String = "TRENDING"
    var body: some View { BadgeView(text: text, style: .trending) }
}
struct SuperhostBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(AppColors.primary)
            Text("SUPERHOST").font(AppTypography.badge)
        }
        .foregroundStyle(AppColors.textPrimary)
        .padding(.vertical, 4).padding(.horizontal, 8)
        .background(AppColors.cardBackground).clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
    }
}
