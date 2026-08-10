import SwiftUI

struct ActivityCard: View {
    let activity: Activity
    var onTap: (() -> Void)? = nil
    var onSave: (() -> Void)? = nil
    var isSaved: Bool = false

    var body: some View {
        RoundedCard(onTap: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: activity.coverImageURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle().fill(AppColors.backgroundSecondary).shimmer()
                        case .success(let img):
                            img.resizable().scaledToFill()
                        case .failure:
                            Rectangle().fill(AppColors.backgroundSecondary).overlay { Image(systemName: "photo").foregroundStyle(AppColors.textTertiary) }
                        @unknown default: Color.gray
                        }
                    }
                    .frame(height: 160)
                    .clipped()

                    if activity.isHot {
                        HotBadgeView()
                            .padding(10)
                    }
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button {
                                onSave?()
                            } label: {
                                Image(systemName: isSaved ? "heart.fill" : "heart")
                                    .foregroundStyle(isSaved ? AppColors.primary : .white)
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                            }
                            .padding(10)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        BadgeView(text: activity.category.displayName, style: .category)
                        Spacer()
                        Text(activity.duration.displayString)
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    Text(activity.title)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(2)
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.caption2).foregroundStyle(AppColors.warning)
                        Text(String(format: "%.1f", activity.rating))
                            .font(AppTypography.caption2)
                            .foregroundStyle(AppColors.textPrimary)
                        Text("(\(activity.reviewCount))")
                            .font(AppTypography.caption2)
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        Text(activity.formattedPrice)
                            .font(AppTypography.bodyBold)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                .padding(12)
            }
        }
        .frame(width: 240)
    }
}

private struct HotBadgeView: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("🔥")
            Text("HOT").font(AppTypography.caption1Bold)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(AppColors.hotBadgeBackground)
        .foregroundStyle(AppColors.hotBadgeText)
        .clipShape(Capsule())
        .appShadow(.xs)
    }
}
