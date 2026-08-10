import SwiftUI

// MARK: - SearchField Style
enum SearchFieldStyle {
    case airbnbBar
    case compact
    case minimal
}

// MARK: - SearchField
struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Where to?"
    var style: SearchFieldStyle = .airbnbBar
    var showFilterButton: Bool = false
    var onFilterTap: (() -> Void)? = nil
    var onSubmit: (() -> Void)? = nil
    var onSearch: (() -> Void)? = nil
    var onClear: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    init(text: Binding<String>,
         placeholder: String = "Where to?",
         style: SearchFieldStyle = .airbnbBar,
         showFilterButton: Bool = false,
         onFilterTap: (() -> Void)? = nil,
         onSubmit: (() -> Void)? = nil,
         onSearch: (() -> Void)? = nil,
         onClear: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.style = style
        self.showFilterButton = showFilterButton
        self.onFilterTap = onFilterTap
        self.onSubmit = onSubmit
        self.onSearch = onSearch
        self.onClear = onClear
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(AppTypography.calloutMedium)
                        .foregroundStyle(AppColors.textSecondary)
                }
                TextField("", text: $text)
                    .focused($isFocused)
                    .font(AppTypography.calloutMedium)
                    .foregroundStyle(AppColors.textPrimary)
                    .submitLabel(.search)
                    .onSubmit {
                        onSubmit?()
                        onSearch?()
                    }
            }

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }

            if showFilterButton {
                Divider().frame(height: 24)
                Button {
                    onFilterTap?()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(AppColors.backgroundSecondary))
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: AppLayout.searchBarHeight)
        .background(AppColors.cardBackground)
        .clipShape(Capsule())
        .overlay {
            Capsule().stroke(isFocused ? AppColors.textPrimary : AppColors.borderLight, lineWidth: isFocused ? 1.5 : 1)
        }
        .shadow(color: Color.black.opacity(isFocused ? 0.14 : 0.08), radius: isFocused ? 16 : 12, x: 0, y: 4)
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}
