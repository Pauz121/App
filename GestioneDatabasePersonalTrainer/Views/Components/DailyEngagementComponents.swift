import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 12

    @State private var animatedProgress = 0.0

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.surfaceSecondary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(animatedProgress, 0), 1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(min(max(animatedProgress, 0), 1) * 100))%")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.45)) {
                animatedProgress = newValue
            }
        }
    }
}

struct MetricMiniCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            Text(value)
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

struct StepsSummaryCard: View {
    let summary: DailyStepSummary?
    let motivation: String
    let isLoading: Bool
    let onRefresh: () -> Void

    var body: some View {
        SectionCard(title: "Passi di oggi", icon: "figure.walk") {
            HStack(alignment: .center, spacing: AppSpacing.lg) {
                ProgressRingView(progress: summary?.progress ?? 0, color: AppColors.successGreen)
                    .frame(width: 108, height: 108)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("\(summary?.steps ?? 0)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("su \(summary?.stepsGoal ?? 10_000) passi")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.textSecondary)
                    Text(motivation)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(action: onRefresh) {
                        Label("Aggiorna passi", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .disabled(isLoading)
                }
            }
        }
    }
}

struct DailyGoalsView: View {
    let goals: [DailyGoal]
    let onTapGoal: (DailyGoal) -> Void

    var body: some View {
        SectionCard(title: "Obiettivi di oggi", icon: "target") {
            if goals.isEmpty {
                Text("Gli obiettivi di oggi verranno mostrati qui.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(goals) { goal in
                        DailyGoalRowView(goal: goal) {
                            onTapGoal(goal)
                        }
                    }
                }
            }
        }
    }
}

struct DailyGoalRowView: View {
    let goal: DailyGoal
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: goal.iconName)
                    .font(.headline)
                    .foregroundStyle(goalColor)
                    .frame(width: 38, height: 38)
                    .background(goalColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(goal.description)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                    if let progressText {
                        Text(progressText)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(goalColor)
                    }
                }

                Spacer()

                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(goal.isCompleted ? AppColors.successGreen : AppColors.textMuted)
            }
            .padding(AppSpacing.sm)
            .background(goal.isCompleted ? AppColors.successGreen.opacity(0.07) : AppColors.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var progressText: String? {
        guard let current = goal.currentValue, let target = goal.targetValue else { return nil }
        let unit = goal.unit.map { " \($0)" } ?? ""
        return "\(Int(current)) / \(Int(target))\(unit)"
    }

    private var goalColor: Color {
        color(named: goal.color)
    }
}

struct StreakCard: View {
    let streak: Streak?
    let fallbackTitle: String

    var body: some View {
        SectionCard(title: "Serie consecutiva", icon: "flame.fill") {
            HStack(spacing: AppSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                        .fill(AppColors.warningYellow.opacity(0.16))
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(AppColors.warningYellow)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 5) {
                    Text(streakText)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)
                    Text(bestText)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                    StatusBadge(text: fallbackTitle, style: .warning)
                }

                Spacer()
            }
        }
    }

    private var streakText: String {
        guard let streak else { return "Inizia la tua serie oggi" }
        return "\(streak.currentCount) giorni di \(streak.streakType.title.lowercased()) consecutivi"
    }

    private var bestText: String {
        guard let streak else { return "Completa il primo check-in per avviare la serie." }
        return "Miglior serie: \(streak.bestCount) giorni"
    }
}

struct HealthPermissionView: View {
    let state: HealthKitAuthorizationState
    let onRequest: () -> Void

    var body: some View {
        SectionCard(title: "Apple Salute", icon: "heart.text.square") {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("L'app chiede accesso ai passi per mostrarti il movimento giornaliero e confrontarlo con gli obiettivi del trainer.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                VStack(alignment: .leading, spacing: 8) {
                    permissionLine("Leggiamo solo i passi da Apple Salute.", icon: "figure.walk")
                    permissionLine("Puoi negare o revocare il consenso dalle impostazioni di Apple Salute.", icon: "lock")
                    permissionLine("I dati non sono usati per diagnosi mediche.", icon: "cross.case")
                }
                if case .denied(let message) = state {
                    Text(message)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.dangerRed)
                }
                PrimaryButton(title: "Collega Apple Salute", systemImage: "heart.fill", action: onRequest)
            }
        }
    }

    private func permissionLine(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 22)
            Text(text)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

struct InsightCard: View {
    let insight: TrainerClientInsight

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: insight.iconName)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Text(insight.message)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
    }

    private var color: Color {
        switch insight.severity {
        case .info: return AppColors.infoBlue
        case .success: return AppColors.successGreen
        case .warning: return AppColors.warningYellow
        case .alert: return AppColors.dangerRed
        }
    }
}

struct TrainerClientInsightsView: View {
    let insights: [TrainerClientInsight]
    let isLoading: Bool

    var body: some View {
        SectionCard(title: "Clienti da seguire", icon: "person.crop.circle.badge.exclamationmark") {
            if isLoading {
                HStack {
                    ProgressView()
                    Text("Analisi clienti in corso")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
            } else if insights.isEmpty {
                Text("Quando check-in, passi o progressi richiedono focus li vedrai qui.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(insights) { insight in
                        InsightCard(insight: insight)
                    }
                }
            }
        }
    }
}

private func color(named name: String) -> Color {
    switch name {
    case "success": return AppColors.successGreen
    case "danger": return AppColors.dangerRed
    case "warning": return AppColors.warningYellow
    case "info": return AppColors.infoBlue
    default: return AppColors.primaryBlack
    }
}
