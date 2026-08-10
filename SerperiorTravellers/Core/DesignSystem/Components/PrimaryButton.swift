import SwiftUI

// MARK: - Button Style Type
enum AppButtonStyle {
    case primary
    case secondary
    case outline
    case ghost
    case destructive

    var backgroundColor: Color {
        switch self {
        case .primary: return AppColors.primary
        case .secondary: return AppColors.secondary
        case .outline: return .clear
        case .ghost: return .clear
        case .destructive: return AppColors.error
        }
    }
    var foregroundColor: Color {
        switch self {
        case .primary: return .white
        case .secondary: return .white
        case .outline: return AppColors.textPrimary
        case .ghost: return AppColors.textPrimary
        case .destructive: return .white
        }
    }
    var borderColor: Color {
        switch self {
        case .outline: return AppColors.border
        case .ghost: return .clear
        default: return .clear
        }
    }
    var pressedBackground: Color {
        switch self {
        case .primary: return AppColors.primaryDark
        case .secondary: return Color(hex: "#000000")
        case .outline: return AppColors.backgroundSecondary
        case .ghost: return AppColors.backgroundSecondary
        case .destructive: return AppColors.errorDark
        }
    }
}

enum AppButtonSize {
    case small
    case medium
    case large
    case extraLarge

    var height: CGFloat {
        switch self {
        case .small: return AppLayout.buttonHeightSmall
        case .medium: return AppLayout.buttonHeightMedium
        case .large: return AppLayout.buttonHeightLarge
        case .extraLarge: return 60
        }
    }
    var font: Font {
        switch self {
        case .small: return AppTypography.buttonSmall
        case .medium: return AppTypography.buttonMedium
        case .large: return AppTypography.buttonLarge
        case .extraLarge: return AppTypography.buttonLarge
        }
    }
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 20
        case .large: return 24
        case .extraLarge: return 32
        }
    }
    var cornerRadius: CGFloat {
        switch self {
        case .small: return AppCornerRadius.s
        case .medium: return AppCornerRadius.button
        case .large: return AppCornerRadius.button
        case .extraLarge: return AppCornerRadius.m
        }
    }
}

// MARK: - PrimaryButton
struct PrimaryButton: View {
    var title: String
    var style: AppButtonStyle = .primary
    var size: AppButtonSize = .large
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var isFullWidth: Bool = true
    var icon: String? = nil
    var iconPosition: IconPosition = .leading
    var action: () -> Void

    enum IconPosition { case leading, trailing }

    // Convenience isEnabled
    var isEnabled: Bool {
        get { !isDisabled }
        set { isDisabled = !newValue }
    }

    init(title: String,
         style: AppButtonStyle = .primary,
         size: AppButtonSize = .large,
         isLoading: Bool = false,
         isDisabled: Bool = false,
         isEnabled: Bool? = nil,
         isFullWidth: Bool = true,
         icon: String? = nil,
         iconPosition: IconPosition = .leading,
         action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.size = size
        self.isLoading = isLoading
        if let enabled = isEnabled {
            self.isDisabled = !enabled
        } else {
            self.isDisabled = isDisabled
        }
        self.isFullWidth = isFullWidth
        self.icon = icon
        self.iconPosition = iconPosition
        self.action = action
    }

    @State private var isPressed = false

    var body: some View {
        Button {
            guard !isLoading, !isDisabled else { return }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(style.foregroundColor).scaleEffect(0.9)
                } else {
                    if let icon, iconPosition == .leading {
                        Image(systemName: icon).font(.system(size: 16, weight: .semibold))
                    }
                    Text(title).font(size.font).lineLimit(1)
                    if let icon, iconPosition == .trailing {
                        Image(systemName: icon).font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous))
            .overlay {
                if style == .outline {
                    RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous).stroke(border, lineWidth: 1)
                }
            }
            .opacity(isDisabled ? 0.45 : 1)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onChanged { _ in isPressed = true }.onEnded { _ in isPressed = false }
        )
    }

    private var background: Color {
        if isPressed { return style.pressedBackground }
        return style.backgroundColor
    }
    private var foreground: Color { style.foregroundColor }
    private var border: Color { style.borderColor }
}

// MARK: - IconButton
struct IconButton: View {
    var icon: String
    var size: CGFloat = 40
    var style: AppButtonStyle = .ghost
    var isFilled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(style.foregroundColor)
                .frame(width: size, height: size)
                .background(isFilled ? AppColors.cardBackground : style.backgroundColor)
                .clipShape(Circle())
                .overlay {
                    if style == .outline { Circle().stroke(AppColors.border, lineWidth: 1) }
                }
                .shadow(color: isFilled ? Color.black.opacity(0.12) : .clear, radius: 8, x: 0, y: 2)
        }
    }
}

// MARK: - Airbnb Gradient Button
struct GradientButton: View {
    var title: String
    var icon: String = "magnifyingglass"
    var isLoading: Bool = false
    var action: () -> Void

    var body: some View {
        Button {
            guard !isLoading else { return }
            let gen = UIImpactFeedbackGenerator(style: .medium)
            gen.impactOccurred()
            action()
        } label: {
            HStack(spacing: 8) {
                if isLoading { ProgressView().tint(.white) }
                else {
                    Image(systemName: icon).font(.system(size: 16, weight: .semibold))
                    Text(title).font(AppTypography.buttonLarge)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity).frame(height: AppLayout.buttonHeightLarge)
            .background(AppColors.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.button, style: .continuous))
            .shadow(color: AppColors.primary.opacity(0.3), radius: 12, x: 0, y: 6)
        }.disabled(isLoading)
    }
}
