import SwiftUI

struct SectionHeader: View {
    var title: String
    var subtitle: String? = nil
    var seeAllText: String? = nil
    var actionTitle: String? = nil // alias for seeAllText
    var showSeeAll: Bool = true
    var seeAllAction: (() -> Void)? = nil

    // Support both init styles
    init(title: String,
         subtitle: String? = nil,
         seeAllText: String? = nil,
         actionTitle: String? = nil,
         showSeeAll: Bool = true,
         seeAllAction: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        // actionTitle is alias for seeAllText, prefer explicit seeAllText if provided
        if let a = actionTitle {
            self.seeAllText = a
            self.actionTitle = a
        } else {
            self.seeAllText = seeAllText
        }
        self.showSeeAll = showSeeAll
        self.seeAllAction = seeAllAction
    }

    // Legacy: init with just title, subtitle, actionTitle string via closure trailing
    init(title: String, subtitle: String? = nil, actionTitle: String? = nil, _ action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.seeAllText = actionTitle
        self.actionTitle = actionTitle
        self.showSeeAll = true
        self.seeAllAction = action
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(AppTypography.title2).foregroundStyle(AppColors.textPrimary).lineLimit(2)
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle).font(AppTypography.subheadline).foregroundStyle(AppColors.textSecondary).lineLimit(2)
                    }
                }
                Spacer(minLength: 16)
                if showSeeAll, let label = (seeAllText ?? actionTitle), let seeAllAction {
                    Button(action: { let gen = UIImpactFeedbackGenerator(style: .light); gen.impactOccurred(); seeAllAction() }) {
                        HStack(spacing: 4) {
                            Text(label).font(AppTypography.subheadlineSemibold)
                            Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(AppColors.textPrimary)
                        .underline()
                    }
                }
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }
}
