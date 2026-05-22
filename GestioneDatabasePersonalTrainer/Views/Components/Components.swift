import SwiftUI

enum StatusBadgeStyle {
    case active
    case pending
    case completed
    case cancelled
    case trialing
    case expired
    case warning
    case info

    var color: Color {
        switch self {
        case .active, .completed:
            return AppColors.successGreen
        case .pending, .info:
            return AppColors.infoBlue
        case .cancelled, .expired:
            return AppColors.dangerRed
        case .trialing, .warning:
            return AppColors.warningYellow
        }
    }

    var foreground: Color {
        switch self {
        case .trialing, .warning:
            return AppColors.textPrimary
        default:
            return color
        }
    }
}

struct StatusBadge: View {
    let text: String
    let style: StatusBadgeStyle

    var body: some View {
        Text(text)
            .font(AppTypography.badge)
            .foregroundStyle(style.foreground)
            .lineLimit(1)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(style.color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(style.color.opacity(0.18), lineWidth: 1)
            )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.11))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(value)
                    .font(AppTypography.number)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 3)
                .padding(.vertical, AppSpacing.md)
                .offset(x: -AppSpacing.md)
        }
        .appCard()
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: 30, height: 30)
                        .background(AppColors.surfaceSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                }
                Text(title)
                    .font(AppTypography.section)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }
            content()
        }
        .appCard()
    }
}

struct PrimaryButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void

    init(title: String, systemImage: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.82)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let systemImage: String?
    let isLoading: Bool
    let action: () -> Void

    init(title: String, systemImage: String? = nil, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(AppColors.textPrimary)
                        .scaleEffect(0.82)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
        }
        .buttonStyle(SecondaryButtonStyle())
        .disabled(isLoading)
    }
}

struct DestructiveButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
        }
        .buttonStyle(DestructiveButtonStyle())
    }
}

struct QuickActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(color)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PillFilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(isSelected ? color : AppColors.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? color : AppColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct MiniProgressBar: View {
    let progress: Double
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppColors.surfaceSecondary)
                Capsule()
                    .fill(color)
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
            }
        }
        .frame(height: 8)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 58, height: 58)
                .background(AppColors.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))

            VStack(spacing: 6) {
                Text(title)
                    .font(AppTypography.section)
                    .foregroundStyle(AppColors.textPrimary)
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xl)
        .appCard()
    }
}

struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.textMuted)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(AppColors.textPrimary)
            if !text.isEmpty {
                Button {
                    withAnimation(.easeOut(duration: 0.18)) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColors.textMuted)
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

struct ClientRowView: View {
    let client: Client

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(AppColors.primaryBlack)
                .frame(width: 48, height: 48)
                .overlay(Text(initials).font(.headline).foregroundStyle(.white))

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: AppSpacing.sm) {
                    Text(client.fullName)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    if client.accessCode.isEmpty {
                        StatusBadge(text: "Da invitare", style: .pending)
                    }
                }
                Text(client.goal.isEmpty ? "Obiettivo non impostato" : client.goal)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 5) {
                Text("\(client.currentWeightKg, specifier: "%.1f") kg")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textMuted)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private var initials: String {
        "\(client.firstName.first.map(String.init) ?? "")\(client.lastName.first.map(String.init) ?? "")"
    }
}

struct WorkoutExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text("\(exercise.order)")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(AppColors.workoutBlack)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 5) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text("\(exercise.sets) serie x \(exercise.reps) - recupero \(exercise.restSeconds)s")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                if !exercise.technicalNotes.isEmpty {
                    Text(exercise.technicalNotes)
                        .font(.caption)
                        .foregroundStyle(AppColors.textMuted)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct MacroNutrientCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(value)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(color.opacity(0.14), lineWidth: 1)
        )
    }
}

struct ProgressPhotoCard: View {
    let title: String
    let photoName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.surfaceSecondary)
                    .frame(height: 126)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )

                Image(systemName: photoName == nil ? "camera.viewfinder" : "person.crop.rectangle.fill")
                    .font(.title2)
                    .foregroundStyle(photoName == nil ? AppColors.textMuted : AppColors.progressGreen)
                    .frame(maxWidth: .infinity, maxHeight: 126)

                StatusBadge(text: title, style: photoName == nil ? .pending : .completed)
                    .padding(8)
            }
        }
    }
}

struct AppointmentRowView: View {
    let appointment: Appointment
    let client: Client?

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: 2)
                .fill(statusColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.startTime.formattedTime())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(durationText)
                    .font(.caption)
                    .foregroundStyle(AppColors.textMuted)
            }
            .frame(width: 66, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(client?.fullName ?? "Cliente")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text(appointment.sessionType.rawValue)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                if !appointment.notes.isEmpty {
                    Text(appointment.notes)
                        .font(.caption)
                        .foregroundStyle(AppColors.textMuted)
                        .lineLimit(2)
                }
            }

            Spacer()

            StatusBadge(text: appointment.status.rawValue, style: badgeStyle)
        }
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .contentShape(Rectangle())
    }

    private var statusColor: Color {
        switch appointment.status {
        case .scheduled: return AppColors.calendarBlue
        case .completed: return AppColors.successGreen
        case .cancelled: return AppColors.textMuted
        }
    }

    private var badgeStyle: StatusBadgeStyle {
        switch appointment.status {
        case .scheduled: return .pending
        case .completed: return .completed
        case .cancelled: return .cancelled
        }
    }

    private var durationText: String {
        let minutes = max(Int(appointment.endTime.timeIntervalSince(appointment.startTime) / 60), 0)
        return "\(minutes) min"
    }
}

struct MachineCard: View {
    let machine: Machine

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .foregroundStyle(AppColors.workoutBlack)
                    .frame(width: 32, height: 32)
                    .background(AppColors.surfaceSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                Text(machine.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                StatusBadge(text: machine.isAvailable ? "Disponibile" : "Pausa", style: machine.isAvailable ? .active : .warning)
            }
            Text(machine.muscleGroup.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.energyOrange)
            Text(machine.description)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
            if !machine.usageNotes.isEmpty {
                Text(machine.usageNotes)
                    .font(.caption)
                    .foregroundStyle(AppColors.textMuted)
            }
        }
        .appCard()
    }
}
