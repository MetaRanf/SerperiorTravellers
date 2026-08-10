import SwiftUI

struct EmptyStateView: View {
    var imageName: String = "airplane.departure"
    var title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 20)
            ZStack {
                Circle().fill(AppColors.backgroundSecondary).frame(width: 80, height: 80)
                Image(systemName: imageName).font(.system(size: 28, weight: .light)).foregroundStyle(AppColors.textSecondary)
            }
            VStack(spacing: 6) {
                Text(title).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundStyle(AppColors.textPrimary).multilineTextAlignment(.center)
                if let subtitle {
                    Text(subtitle).font(.system(size: 14)).foregroundStyle(AppColors.textSecondary).multilineTextAlignment(.center).padding(.horizontal, 24)
                }
            }
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle).font(.system(size: 14, weight: .semibold, design: .rounded)).foregroundStyle(.white).padding(.horizontal, 20).padding(.vertical, 10).background(AppColors.primary, in: Capsule())
                }
                .padding(.top, 4)
            }
            Spacer(minLength: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(AppColors.background)
    }
}
