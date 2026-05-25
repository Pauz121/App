import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.bgMain.ignoresSafeArea()
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [DesignSystem.Colors.indigo.opacity(0.08), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 260)
                    .ignoresSafeArea()
                    Spacer()
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(colors: [DesignSystem.Colors.indigo, DesignSystem.Colors.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                                .shadow(color: DesignSystem.Colors.indigo.opacity(0.3), radius: 8, x: 0, y: 4)
                            Text("FitConsole")
                                .font(.custom("Archivo-ExtraBold", size: 16))
                                .foregroundStyle(DesignSystem.Colors.txtPrimary)
                        }
                        Spacer()
                        Text("v2.0")
                            .font(DesignSystem.Typography.labelSM())
                            .foregroundStyle(DesignSystem.Colors.txtSecondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(DesignSystem.Colors.bgCard)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(DesignSystem.Colors.bgLine, lineWidth: 1))
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, 20)

                    Spacer()

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                featureChip("🏋️", "Schede")
                                featureChip("🥗", "Piani")
                                featureChip("📅", "Agenda")
                                featureChip("📊", "Progressi")
                                featureChip("💬", "Chat")
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("Il tuo gestionale\nfitness, nativo iOS.")
                                .font(.custom("Archivo-ExtraBold", size: 36))
                                .foregroundStyle(DesignSystem.Colors.txtPrimary)
                                .lineSpacing(3)
                            Text("Clienti, schede, nutrizione e appuntamenti in un'unica app professionale per personal trainer.")
                                .font(DesignSystem.Typography.bodyMD())
                                .foregroundStyle(DesignSystem.Colors.txtSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        NavigationLink {
                            LoginSelectionView()
                        } label: {
                            Label("Inizia ora", systemImage: "arrow.right")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, 44)
                    }
                }
            }
        }
    }

    private func featureChip(_ icon: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(icon).font(.system(size: 13))
            Text(label)
                .font(DesignSystem.Typography.labelSM())
                .foregroundStyle(DesignSystem.Colors.txtPrimary)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(DesignSystem.Colors.bgCard)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(DesignSystem.Colors.bgLine, lineWidth: 1))
    }
}

struct LoginSelectionView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                VStack(spacing: AppSpacing.sm) {
                    Text("Come vuoi accedere?")
                        .font(DesignSystem.Typography.titleLG())
                        .foregroundStyle(DesignSystem.Colors.txtPrimary)
                    Text("Scegli il tuo ruolo per continuare")
                        .font(DesignSystem.Typography.bodyMD())
                        .foregroundStyle(DesignSystem.Colors.txtSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

                NavigationLink {
                    TrainerPlanSelectionView()
                } label: {
                    AccessChoiceCard(
                        title: "Personal Trainer",
                        subtitle: "Gestisci clienti, schede, nutrizione e appuntamenti",
                        icon: "person.crop.rectangle.stack",
                        gradient: [DesignSystem.Colors.indigo, DesignSystem.Colors.teal]
                    )
                }

                NavigationLink {
                    ClientAccessCodeView()
                } label: {
                    AccessChoiceCard(
                        title: "Cliente",
                        subtitle: "Segui i tuoi allenamenti e il piano del tuo trainer",
                        icon: "figure.run",
                        gradient: [DesignSystem.Colors.amber, DesignSystem.Colors.limeDark]
                    )
                }

                if AppConfiguration.isDemoLoginEnabled {
                    FitCard {
                        VStack(spacing: AppSpacing.sm) {
                            HStack(spacing: 8) {
                                Image(systemName: "hammer.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(DesignSystem.Colors.txtSecondary)
                                Text("DEMO SVILUPPO")
                                    .font(DesignSystem.Typography.labelSM())
                                    .tracking(1.4)
                                    .foregroundStyle(DesignSystem.Colors.txtSecondary)
                                Spacer()
                            }
                            SecondaryButton(title: "Trainer Demo", systemImage: "person.crop.rectangle") {
                                authViewModel.loginTrainerDemo()
                            }
                            SecondaryButton(title: "Cliente Demo", systemImage: "person") {
                                authViewModel.loginClientDemo()
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Accesso")
        .navigationBarTitleDisplayMode(.inline)
        .appScreen()
    }
}

private struct AccessChoiceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 52, height: 52)
                .background(
                    LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: gradient.first?.opacity(0.28) ?? .clear, radius: 8, x: 0, y: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.labelMD())
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(DesignSystem.Typography.bodySM())
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.textMuted)
        }
        .appCard()
    }
}

struct TrainerPlanSelectionView: View {
    @State private var selectedPlan = "trial_15"

    private let plans: [(slug: String, name: String, description: String, price: String, clients: String)] = [
        ("trial_15", "Free Trial 15 giorni", "Prova gratuita per validare il gestionale.", "0 EUR", "5 clienti"),
        ("basic", "Basic", "Per trainer indipendenti.", "19,90 EUR/mese", "20 clienti"),
        ("pro", "Pro", "Per trainer in crescita.", "49,90 EUR/mese", "60 clienti"),
        ("studio", "Studio", "Per studi e team.", "99,90 EUR/mese", "500 clienti")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Scegli il piano")
                        .font(AppTypography.title)
                    Text("Il pagamento reale verra collegato in seguito. Ora il piano viene registrato in Supabase.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                }

                ForEach(plans, id: \.slug) { plan in
                    Button {
                        selectedPlan = plan.slug
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: selectedPlan == plan.slug ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedPlan == plan.slug ? DesignSystem.Colors.indigo : AppColors.textSecondary)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(plan.name)
                                    .font(DesignSystem.Typography.labelMD())
                                    .foregroundStyle(DesignSystem.Colors.txtPrimary)
                                Text(plan.description)
                                    .font(DesignSystem.Typography.bodySM())
                                    .foregroundStyle(AppColors.textSecondary)
                                Text("\(plan.price) · \(plan.clients)")
                                    .font(DesignSystem.Typography.labelSM())
                                    .foregroundStyle(DesignSystem.Colors.indigo)
                            }
                            Spacer()
                        }
                        .foregroundStyle(AppColors.textPrimary)
                        .appCard()
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink {
                    TrainerRegistrationView(selectedPlanSlug: selectedPlan)
                } label: {
                    Label("Continua", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle())

                NavigationLink {
                    TrainerLoginView()
                } label: {
                    Text("Hai gia un account? Accedi")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Piani")
        .navigationBarTitleDisplayMode(.inline)
        .appScreen()
    }
}

struct TrainerRegistrationView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    let selectedPlanSlug: String

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            LinearGradient(colors: [DesignSystem.Colors.indigo, DesignSystem.Colors.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(color: DesignSystem.Colors.indigo.opacity(0.3), radius: 12, x: 0, y: 5)
                    Text("Crea il tuo account")
                        .font(DesignSystem.Typography.titleLG())
                        .foregroundStyle(DesignSystem.Colors.txtPrimary)
                    Text(selectedPlanSlug.uppercased())
                        .font(DesignSystem.Typography.labelSM())
                        .foregroundStyle(DesignSystem.Colors.indigo)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(DesignSystem.Colors.indigoBg)
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)

                SectionLabel(text: "Dati personali")
                FitInputField(label: "Nome", text: $authViewModel.firstName)
                FitInputField(label: "Cognome", text: $authViewModel.lastName)
                FitInputField(label: "Nome studio o attività", text: $authViewModel.businessName)

                SectionLabel(text: "Credenziali")
                FitInputField(label: "Email", text: $authViewModel.email, keyboardType: .emailAddress, autoCapitalize: .never)
                FitInputField(label: "Password", text: $authViewModel.password, secure: true)

                if let message = authViewModel.errorMessage {
                    Text(message)
                        .font(DesignSystem.Typography.labelSM())
                        .foregroundStyle(AppColors.dangerRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                AccentButton(title: authViewModel.isLoading ? "Creo account…" : "Crea account", color: DesignSystem.Colors.indigo) {
                    authViewModel.selectedPlanSlug = selectedPlanSlug
                    authViewModel.registerTrainer()
                }
                .disabled(authViewModel.firstName.isEmpty || authViewModel.lastName.isEmpty || authViewModel.businessName.isEmpty)

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Registrazione")
        .navigationBarTitleDisplayMode(.inline)
        .appScreen()
    }
}

struct TrainerLoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "person.crop.rectangle.stack")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 68, height: 68)
                        .background(
                            LinearGradient(colors: [DesignSystem.Colors.indigo, DesignSystem.Colors.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: DesignSystem.Colors.indigo.opacity(0.35), radius: 14, x: 0, y: 6)
                    Text("Accesso Trainer")
                        .font(DesignSystem.Typography.titleLG())
                        .foregroundStyle(DesignSystem.Colors.txtPrimary)
                    Text("Inserisci le tue credenziali per accedere")
                        .font(DesignSystem.Typography.bodyMD())
                        .foregroundStyle(DesignSystem.Colors.txtSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

                VStack(spacing: 10) {
                    FitInputField(label: "Email", text: $authViewModel.email, keyboardType: .emailAddress, autoCapitalize: .never)
                    FitInputField(label: "Password", text: $authViewModel.password, secure: true)
                }

                if let message = authViewModel.errorMessage {
                    Text(message)
                        .font(DesignSystem.Typography.labelSM())
                        .foregroundStyle(AppColors.dangerRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                AccentButton(title: authViewModel.isLoading ? "Accesso in corso…" : "Entra", color: DesignSystem.Colors.indigo) {
                    authViewModel.loginTrainer()
                }

                if AppConfiguration.isDemoLoginEnabled {
                    SecondaryButton(title: "Trainer Demo", systemImage: "person.crop.rectangle") {
                        authViewModel.loginTrainerDemo()
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Trainer")
        .navigationBarTitleDisplayMode(.inline)
        .appScreen()
    }
}

struct ClientAccessCodeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var mode: ClientLoginMode = .code

    private enum ClientLoginMode: CaseIterable, Hashable {
        case code, email
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 68, height: 68)
                        .background(
                            LinearGradient(colors: [DesignSystem.Colors.amber, DesignSystem.Colors.limeDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: DesignSystem.Colors.amber.opacity(0.35), radius: 14, x: 0, y: 6)
                    Text("Accesso Cliente")
                        .font(DesignSystem.Typography.titleLG())
                        .foregroundStyle(DesignSystem.Colors.txtPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

                SegmentedPicker(
                    options: ClientLoginMode.allCases,
                    selection: $mode,
                    title: { $0 == .code ? "Codice invito" : "Email & Password" },
                    accent: DesignSystem.Colors.limeDark
                )

                if mode == .code {
                    VStack(spacing: 10) {
                        FitInputField(label: "Codice accesso (PT-XXXXXXXX)", text: $authViewModel.accessCode, autoCapitalize: .characters)
                        FitInputField(label: "Email", text: $authViewModel.email, keyboardType: .emailAddress, autoCapitalize: .never)
                        FitInputField(label: "Password", text: $authViewModel.password, secure: true)
                    }

                    if let message = authViewModel.errorMessage {
                        Text(message)
                            .font(DesignSystem.Typography.labelSM())
                            .foregroundStyle(AppColors.dangerRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AccentButton(title: authViewModel.isLoading ? "Registrazione…" : "Registrati con codice", color: DesignSystem.Colors.limeDark) {
                        authViewModel.registerClientWithInviteCode()
                    }
                } else {
                    VStack(spacing: 10) {
                        FitInputField(label: "Email", text: $authViewModel.email, keyboardType: .emailAddress, autoCapitalize: .never)
                        FitInputField(label: "Password", text: $authViewModel.password, secure: true)
                    }

                    if let message = authViewModel.errorMessage {
                        Text(message)
                            .font(DesignSystem.Typography.labelSM())
                            .foregroundStyle(AppColors.dangerRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    AccentButton(title: authViewModel.isLoading ? "Accesso…" : "Accedi", color: DesignSystem.Colors.limeDark) {
                        authViewModel.loginClientWithEmail()
                    }
                }

                if AppConfiguration.isDemoLoginEnabled {
                    SecondaryButton(title: "Cliente Demo", systemImage: "person") {
                        authViewModel.loginClientDemo()
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Cliente")
        .navigationBarTitleDisplayMode(.inline)
        .appScreen()
    }
}

struct ClientAccessCodeRegistrationView: View {
    var body: some View {
        ClientAccessCodeView()
    }
}
