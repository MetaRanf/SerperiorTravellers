import SwiftUI

struct PropertyCard: View {
    let property: Property
    var isWishlisted: Bool = false
    var onTap: (() -> Void)? = nil
    var onWishlistTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: property.coverImageURL) { phase in
                        switch phase {
                        case .empty: Rectangle().fill(AppColors.backgroundSecondary).shimmer().frame(height: 200)
                        case .success(let img): img.resizable().scaledToFill().frame(height: 200).clipped()
                        case .failure: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 200).overlay(Image(systemName: "photo"))
                        @unknown default: Color.gray.frame(height: 200)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))

                    if property.isTrending {
                        BadgeView(text: "Guest favourite", style: .trending)
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }

                    Button {
                        onWishlistTap?()
                    } label: {
                        Image(systemName: isWishlisted ? "heart.fill" : "heart")
                            .foregroundStyle(isWishlisted ? AppColors.primary : .white)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(8)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(8)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(property.title).font(AppTypography.bodySemibold).foregroundStyle(AppColors.textPrimary).lineLimit(1)
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill").font(.caption2).foregroundStyle(AppColors.warning)
                            Text(String(format: "%.1f", property.rating)).font(AppTypography.caption1Semibold).foregroundStyle(AppColors.textPrimary)
                        }
                    }
                    Text(property.type.displayName + " • \(property.maxGuests) guests").font(AppTypography.caption1).foregroundStyle(AppColors.textSecondary).lineLimit(1)
                    HStack {
                        Text("\(property.currency.symbol)\(NSDecimalNumber(decimal: property.pricePerNight))").font(AppTypography.bodySemibold).foregroundStyle(AppColors.textPrimary)
                        Text("night").font(AppTypography.caption1).foregroundStyle(AppColors.textSecondary)
                        Spacer()
                        if property.isSuperhost {
                            SuperhostBadge()
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
            }
        }
        .buttonStyle(.plain)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.card, style: .continuous))
        .appShadow(.card)
    }
}
