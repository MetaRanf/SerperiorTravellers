import SwiftUI

public struct SurpriseMeCard: View {
    public var onSurprise: (Decimal) -> Void = { _ in }
    @State private var budget: String = "1500"

    public init(onSurprise: @escaping (Decimal) -> Void = { _ in }) { self.onSurprise = onSurprise }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Surprise Me").typography(AppTypography.title3)
                    Text("Tell us budget & dates, we craft a perfect escape").typography(AppTypography.caption1, color: AppColors.textSecondary)
                }
                Spacer()
                ZStack { Circle().fill(AppColors.primaryGradient).frame(width: 44, height: 44); Text("✨").font(.system(size: 20)) }
            }

            HStack(spacing: 10) {
                HStack(spacing: 4) {
                    Text("$").typography(AppTypography.calloutSemibold)
                    TextField("Budget", text: $budget).keyboardType(.numberPad).typography(AppTypography.calloutMedium)
                }
                .padding(.horizontal, 12).frame(height: 40).background(AppColors.backgroundSecondary, in: RoundedRectangle(cornerRadius: 10))

                Button {
                    let dec = Decimal(string: budget) ?? Decimal(1500)
                    onSurprise(dec)
                } label: {
                    Text("Surprise").typography(AppTypography.buttonSmall, color: .white).padding(.horizontal, 18).frame(height: 40).background(AppColors.primary, in: Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(AppColors.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppColors.borderLight, lineWidth: 1))
        .cardShadow()
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }
}

public struct SurpriseMeResultView: View {
    public let response: SurpriseMeResponse
    public var onBook: (() -> Void)? = nil
    public init(response: SurpriseMeResponse, onBook: (() -> Void)? = nil) { self.response = response; self.onBook = onBook }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: response.suggestedOption.coverImageURL) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill().frame(height: 220).clipped()
                    default: Rectangle().fill(AppColors.backgroundSecondary).frame(height: 220)
                    }
                }.clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Your match: \(response.suggestedOption.destination.name)").typography(AppTypography.title2)
                    Text(response.reasoning).typography(AppTypography.subheadline, color: AppColors.textSecondary).lineSpacing(2)
                    Divider()
                    Text("Includes").typography(AppTypography.headline)
                    ForEach(response.suggestedOption.featuredProperties.prefix(2)) { prop in
                        Label(prop.title, systemImage: "bed.double").typography(AppTypography.caption1)
                    }
                    ForEach(response.suggestedOption.featuredActivities.prefix(3)) { act in
                        Label(act.title, systemImage: "ticket").typography(AppTypography.caption1)
                    }
                    PrimaryButton(title: "Book – \(response.suggestedOption.currency.symbol)\(NSDecimalNumber(decimal: response.suggestedOption.totalPriceEstimate))") { onBook?() }
                }
            }.padding(20)
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
