import SwiftUI

struct ShimmerView: View {
    var cornerRadius: CGFloat = AppCornerRadius.card
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppColors.backgroundSecondary)
            .shimmer()
    }
}

struct PropertyCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShimmerView()
                .frame(height: 200)
            VStack(alignment: .leading, spacing: 8) {
                ShimmerView(cornerRadius: 6).frame(height: 16).frame(width: 180)
                ShimmerView(cornerRadius: 6).frame(height: 12).frame(width: 120)
                ShimmerView(cornerRadius: 6).frame(height: 12).frame(width: 80)
            }
        }
    }
}

struct ActivityCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ShimmerView().frame(height: 160)
            ShimmerView(cornerRadius: 6).frame(height: 14).frame(width: 140)
            ShimmerView(cornerRadius: 6).frame(height: 12).frame(width: 180)
        }
        .frame(width: 240)
    }
}
