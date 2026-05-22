import SwiftUI

enum AppColors {
    static let appBackground = Color(hex: 0xFAFAF8)
    static let background = appBackground
    static let surface = Color(hex: 0xFFFFFF)
    static let surfaceSecondary = Color(hex: 0xF1F1EE)
    static let elevatedSurface = surfaceSecondary
    static let border = Color(hex: 0xE5E5E0)

    static let textPrimary = Color(hex: 0x111111)
    static let textSecondary = Color(hex: 0x666666)
    static let textMuted = Color(hex: 0x9A9A9A)

    static let primaryBlack = Color(hex: 0x111111)
    static let primaryBlackPressed = Color(hex: 0x000000)

    static let successGreen = Color(hex: 0x21A67A)
    static let dangerRed = Color(hex: 0xE5484D)
    static let warningYellow = Color(hex: 0xF5B942)
    static let infoBlue = Color(hex: 0x3B82F6)
    static let energyOrange = Color(hex: 0xFF7A1A)

    static let muscleRed = Color(hex: 0xD84D4D)
    static let progressGreen = successGreen
    static let nutritionYellow = Color(hex: 0xF2C94C)
    static let calendarBlue = Color(hex: 0x4D8DFF)
    static let workoutBlack = primaryBlack

    static let accent = primaryBlack
    static let success = successGreen
    static let violet = energyOrange
    static let warning = warningYellow
    static let divider = border
}

enum AppSpacing {
    static let xs: CGFloat = 6
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
}

enum AppTypography {
    static let hero = Font.system(size: 34, weight: .bold, design: .default)
    static let title = Font.system(size: 26, weight: .bold, design: .default)
    static let section = Font.system(size: 19, weight: .semibold, design: .default)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let badge = Font.system(size: 11, weight: .semibold, design: .default)
    static let number = Font.system(size: 30, weight: .bold, design: .rounded)
}

struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppSpacing.md)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.035), radius: 10, x: 0, y: 5)
    }
}

struct AppScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.appBackground)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isEnabled ? (configuration.isPressed ? AppColors.primaryBlackPressed : AppColors.primaryBlack) : AppColors.textMuted)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(isEnabled ? AppColors.textPrimary : AppColors.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(configuration.isPressed ? AppColors.surfaceSecondary : AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isEnabled ? AppColors.dangerRed.opacity(configuration.isPressed ? 0.78 : 1) : AppColors.textMuted)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardStyle())
    }

    func appScreen() -> some View {
        modifier(AppScreenBackground())
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
