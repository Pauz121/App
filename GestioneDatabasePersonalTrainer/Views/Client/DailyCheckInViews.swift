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
    @State private var currentStep = 0
    @State private var didSubmit = false
    @State private var completionAnimated = false

    private let steps: [CheckInStep] = [
        CheckInStep(category: "Come ti senti", title: "Quanta energia hai oggi?", hint: "Scegli la faccia che descrive meglio il tuo livello.", keyPath: \.energyLevel),
        CheckInStep(category: "Riposo", title: "Come hai dormito?", hint: "Il sonno cambia molto il recupero.", keyPath: \.sleepQuality),
        CheckInStep(category: "Alimentazione", title: "Quanta fame hai avuto?", hint: "Aiuta il coach a capire sazieta e aderenza.", keyPath: \.hungerLevel),
        CheckInStep(category: "Mente", title: "Quanto stress senti?", hint: "Serve a calibrare carico e recupero.", keyPath: \.stressLevel),
        CheckInStep(category: "Altro", title: "Vuoi aggiungere qualcosa?", hint: "Una nota libera per il tuo coach.", keyPath: \.energyLevel)
    ]

    var body: some View {
        ZStack {
            DesignSystem.Colors.bgMain.ignoresSafeArea()
            if didSubmit {
                completionView
                    .transition(.scale.combined(with: .opacity))
            } else {
                flowView
            }
        }
        .onChange(of: viewModel.isSaving) { _, isSaving in
            if !isSaving && viewModel.errorMessage == nil {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
                    didSubmit = true
                    completionAnimated = true
                }
            }
        }
    }

    private var flowView: some View {
        VStack(spacing: 0) {
            HStack {
                Button("✕ Chiudi", action: onClose)
                    .font(DesignSystem.Typography.labelMD())
                    .foregroundStyle(DesignSystem.Colors.limeDark)
                Spacer()
                Text("\(currentStep + 1) di 5")
                    .font(DesignSystem.Typography.labelMD())
                    .foregroundStyle(DesignSystem.Colors.txtSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(DesignSystem.Colors.bgLine)
                    Capsule()
                        .fill(DesignSystem.Colors.lime)
                        .frame(width: proxy.size.width * CGFloat(currentStep + 1) / 5)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .animation(.easeInOut(duration: 0.3), value: currentStep)

            ScrollView {
                VStack(alignment: .center, spacing: 18) {
                    SectionLabel(text: steps[currentStep].category)
                        .frame(maxWidth: .infinity)
                    Text(steps[currentStep].title)
                        .font(.custom("Archivo-ExtraBold", size: 26))
                        .foregroundStyle(DesignSystem.Colors.txtPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Text(steps[currentStep].hint)
                        .font(DesignSystem.Typography.labelMD())
                        .foregroundStyle(DesignSystem.Colors.txtSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    if currentStep == 4 {
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $viewModel.notes)
                                .font(DesignSystem.Typography.bodyMD())
                                .frame(minHeight: 190)
                                .padding(10)
                                .background(DesignSystem.Colors.bgCard)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(DesignSystem.Colors.bgLine, lineWidth: 1))
                            if viewModel.notes.isEmpty {
                                Text("Scrivi una nota al tuo coach…")
                                    .font(DesignSystem.Typography.bodyMD())
                                    .foregroundStyle(DesignSystem.Colors.txtSecondary.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 18)
                                    .allowsHitTesting(false)
                            }
                        }
                    } else {
                        ScrollableEmojiRating(value: binding(for: steps[currentStep]))
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(DesignSystem.Typography.labelSM())
                            .foregroundStyle(AppColors.dangerRed)
                    }
                }
                .padding(20)
            }

            AccentButton(title: currentStep == 4 ? "Invia check ✓" : "Continua ->", color: DesignSystem.Colors.limeDark) {
                if currentStep < 4 {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        currentStep += 1
                    }
                } else {
                    viewModel.save()
                }
            }
            .padding(20)
            .disabled(viewModel.isSaving)
        }
    }

    private var completionView: some View {
        VStack(spacing: 18) {
            Circle()
                .fill(DesignSystem.Colors.limeBg)
                .frame(width: 110, height: 110)
                .scaleEffect(completionAnimated ? 1 : 0.75)
                .shadow(color: DesignSystem.Colors.lime.opacity(0.32), radius: 22)
                .overlay(Text("🎉").font(.system(size: 50)))
            Text("Check fatto!")
                .font(.custom("Archivo-Black", size: 30))
                .foregroundStyle(DesignSystem.Colors.txtPrimary)
            Text("Marco ricevera come stai andando. Continua cosi.")
                .font(DesignSystem.Typography.bodyMD())
                .foregroundStyle(DesignSystem.Colors.txtSecondary)
                .multilineTextAlignment(.center)
            Text("3 giorni di fila!")
                .font(DesignSystem.Typography.labelSM())
                .foregroundStyle(DesignSystem.Colors.amber)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(DesignSystem.Colors.amberBg)
                .clipShape(Capsule())
            FitCard {
                HStack(alignment: .top, spacing: 12) {
                    AvatarView(initials: "MC", gradient: [DesignSystem.Colors.indigo, DesignSystem.Colors.teal], size: 38)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Marco")
                            .font(DesignSystem.Typography.labelMD())
                            .foregroundStyle(DesignSystem.Colors.txtPrimary)
                        Text(autoMessage)
                            .font(DesignSystem.Typography.bodyMD())
                            .foregroundStyle(DesignSystem.Colors.txtSecondary)
                    }
                }
            }
            AccentButton(title: "Torna alla home", color: DesignSystem.Colors.limeDark, action: onClose)
        }
        .padding(26)
    }

    private var autoMessage: String {
        if viewModel.energyLevel <= 2 {
            return "Ho visto energia bassa: oggi tieni il ritmo controllato e dimmi se serve alleggerire il carico."
        }
        if viewModel.energyLevel >= 4 {
            return "Ottimo livello di energia. Teniamo alta la qualita delle ripetizioni."
        }
        return "Check-in ricevuto. Continuiamo con il piano e monitoriamo recupero e fame."
    }

    private func binding(for step: CheckInStep) -> Binding<Int> {
        Binding(
            get: { viewModel[keyPath: step.keyPath] },
            set: { viewModel[keyPath: step.keyPath] = $0 }
        )
    }
}

private struct CheckInStep {
    let category: String
    let title: String
    let hint: String
    let keyPath: ReferenceWritableKeyPath<DailyCheckInViewModel, Int>
}

private struct ScrollableEmojiRating: View {
    @Binding var value: Int
    private let options: [(score: Int, emoji: String, label: String)] = [
        (1, "😣", "Pessima"),
        (2, "😕", "Non bene"),
        (3, "😐", "Nella media"),
        (4, "🙂", "Bene"),
        (5, "😄", "Ottimo")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.score) { option in
                    let isSelected = value == option.score
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.68)) {
                            value = option.score
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Text(option.emoji)
                                .font(.system(size: 34))
                            Text(option.label)
                                .font(DesignSystem.Typography.labelSM())
                                .foregroundStyle(isSelected ? DesignSystem.Colors.limeDark : DesignSystem.Colors.txtSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 90, height: 100)
                        .background(isSelected ? DesignSystem.Colors.limeBg : DesignSystem.Colors.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(isSelected ? DesignSystem.Colors.lime : DesignSystem.Colors.bgLine, lineWidth: isSelected ? 2 : 1)
                        )
                        .scaleEffect(isSelected ? 1.04 : 1)
                        .shadow(color: isSelected ? DesignSystem.Colors.lime.opacity(0.22) : .clear, radius: 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
}
