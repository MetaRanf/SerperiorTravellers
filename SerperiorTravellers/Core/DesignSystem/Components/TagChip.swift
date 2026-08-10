import SwiftUI

public struct TagChip: View {
    public let title: String
    public var icon: String? = nil
    public var isSelected: Bool = false
    public var action: (() -> Void)? = nil

    public init(title: String, icon: String? = nil, isSelected: Bool = false, action: (() -> Void)? = nil) {
        self.title = title; self.icon = icon; self.isSelected = isSelected; self.action = action
    }

    public var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 12, weight: .medium))
                }
                Text(title).font(AppTypography.caption1Medium)
            }
            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(isSelected ? AppColors.textPrimary : AppColors.cardBackground)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(isSelected ? Color.clear : AppColors.borderLight, lineWidth: 1))
            .shadow(color: isSelected ? .clear : Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

public struct RatingView: View {
    public var rating: Double
    public var reviewCount: Int? = nil
    public var size: CGFloat = 12

    public init(rating: Double, reviewCount: Int? = nil, size: CGFloat = 12) {
        self.rating = rating; self.reviewCount = reviewCount; self.size = size
    }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill").font(.system(size: size, weight: .semibold)).foregroundStyle(AppColors.star)
            Text(String(format: "%.1f", rating)).font(AppTypography.caption1Semibold).foregroundStyle(AppColors.textPrimary)
            if let reviewCount {
                Text("(\(reviewCount))").font(AppTypography.caption1).foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}

public struct PriceLabel: View {
    public var money: Money?
    public var amount: Decimal
    public var currency: Currency
    public var suffix: String? = "/night"

    public init(amount: Decimal, currency: Currency = .usd, suffix: String? = "/night") {
        self.amount = amount; self.currency = currency; self.suffix = suffix; self.money = nil
    }

    public init(money: Money, suffix: String? = "/night") {
        self.money = money; self.amount = money.amount; self.currency = money.currency; self.suffix = suffix
    }

    public var body: some View {
        HStack(spacing: 2) {
            Text("\(currency.symbol)\(NSDecimalNumber(decimal: amount))").font(AppTypography.price).foregroundStyle(AppColors.textPrimary)
            if let suffix {
                Text(suffix).font(AppTypography.caption1).foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
