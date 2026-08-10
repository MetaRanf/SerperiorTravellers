import SwiftUI

public struct VacationCarousel: View {
    public let options: [VacationOption]
    public var onTap: (VacationOption) -> Void = { _ in }

    public init(options: [VacationOption], onTap: @escaping (VacationOption) -> Void = { _ in }) {
        self.options = options; self.onTap = onTap
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.ml) {
                ForEach(options) { option in
                    VacationCarouselCard(option: option) { onTap(option) }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.s)
        }
    }
}

public struct VacationCarouselCard: View {
    public let option: VacationOption
    public var onTap: () -> Void
    public init(option: VacationOption, onTap: @escaping () -> Void) { self.option = option; self.onTap = onTap }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: option.coverImageURL) { phase in
                        switch phase {
                        case .empty: Rectangle().fill(AppColors.backgroundSecondary).shimmer()
                        case .success(let img): img.resizable().scaledToFill()
                        case .failure: Rectangle().fill(AppColors.backgroundSecondary).overlay(Image(systemName: "photo"))
                        @unknown default: Color.gray
                        }
                    }
                    .frame(width: 280, height: 180).clipped()

                    if option.isTrending {
                        BadgeView(text: "Popular", style: .hot).padding(10)
                    }

                    VStack {
                        Spacer()
                        LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom).frame(height: 80)
                    }
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.destination.name).typography(AppTypography.headline, color: .white)
                                Text(option.destination.country).typography(AppTypography.caption1, color: .white.opacity(0.8))
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("from").typography(AppTypography.caption2, color: .white.opacity(0.8))
                                Text("\(option.currency.symbol)\(NSDecimalNumber(decimal: option.totalPriceEstimate))").typography(AppTypography.bodyBold, color: .white)
                            }
                        }.padding(12)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    if let tagline = option.tagline {
                        Text(tagline).typography(AppTypography.caption1Semibold, color: AppColors.textSecondary).lineLimit(1)
                    }
                    HStack {
                        RatingView(rating: option.averageRating)
                        Text("•").foregroundStyle(AppColors.textTertiary)
                        Text("\(option.nights) nights").typography(AppTypography.caption1, color: AppColors.textSecondary)
                    }
                }.padding(12)
            }
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.cardLarge, style: .continuous))
            .appShadow(.card)
            .frame(width: 280)
        }
        .buttonStyle(.plain)
    }
}
