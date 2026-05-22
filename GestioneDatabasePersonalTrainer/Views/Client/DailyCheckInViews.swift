import SwiftUI

struct DailyCheckInSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DailyCheckInViewModel

    init(client: Client, existing: DailyCheckIn?, services: AppServices, onSaved: @escaping (DailyCheckIn) -> Void) {
        _viewModel = StateObject(wrappedValue: DailyCheckInViewModel(
            client: client,
            existing: existing,
            checkInService: services.dailyCheckInService,
            streakService: services.streakService,
            onSaved: onSaved
        ))
    }

    var body: some View {
        DailyCheckInView(viewModel: viewModel) {
            dismiss()
        }
    }
}

struct DailyCheckInView: View {
    @ObservedObject var viewModel: DailyCheckInViewModel
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    SectionCard(title: "Come sta andando oggi?", icon: "checklist") {
                        RatingControl(title: "Energia", value: $viewModel.energyLevel, icon: "bolt.fill")
                        RatingControl(title: "Sonno", value: $viewModel.sleepQuality, icon: "moon.fill")
                        RatingControl(title: "Fame", value: $viewModel.hungerLevel, icon: "fork.knife")
                        RatingControl(title: "Stress", value: $viewModel.stressLevel, icon: "brain.head.profile")
                    }

                    SectionCard(title: "Abitudini", icon: "slider.horizontal.3") {
                        ToggleRow(title: "Dolori muscolari", icon: "figure.cooldown", isOn: $viewModel.muscleSoreness)
                        ToggleRow(title: "Allenamento completato", icon: "checkmark.circle", isOn: $viewModel.workoutCompleted)

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Label("Dieta rispettata", systemImage: "leaf")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.textPrimary)
                            Picker("Dieta rispettata", selection: $viewModel.dietAdherence) {
                                ForEach(DietAdherence.allCases) { option in
                                    Text(option.label).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    SectionCard(title: "Note", icon: "note.text") {
                        TextEditor(text: $viewModel.notes)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(AppColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                                    .stroke(AppColors.border, lineWidth: 1)
                            )
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppColors.dangerRed)
                    }

                    PrimaryButton(title: "Salva check-in", systemImage: "checkmark.circle", isLoading: viewModel.isSaving) {
                        viewModel.save()
                    }
                }
                .padding(AppSpacing.lg)
            }
            .navigationTitle("Check-in")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") { onClose() }
                }
            }
            .appScreen()
            .onChange(of: viewModel.isSaving) { _, isSaving in
                if !isSaving && viewModel.errorMessage == nil {
                    onClose()
                }
            }
        }
    }
}

private struct RatingControl: View {
    let title: String
    @Binding var value: Int
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text("\(value)/5")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { score in
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) {
                            value = score
                        }
                    } label: {
                        Text("\(score)")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(score <= value ? .white : AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(score <= value ? AppColors.primaryBlack : AppColors.surfaceSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
        }
        .tint(AppColors.primaryBlack)
    }
}
