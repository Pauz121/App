import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                Spacer()

                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundStyle(AppColors.accent)

                    Text("Gestione Database Personal Trainer")
                        .font(AppTypography.hero)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(4)
                        .minimumScaleFactor(0.78)

                    Text("Clienti, schede, nutrizione, appuntamenti e progressi in un unico gestionale nativo iOS.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                NavigationLink {
                    LoginSelectionView()
                } label: {
                    Label("Inizia", systemImage: "arrow.right")
                }
                .buttonStyle(PrimaryButtonStyle())

                Spacer()
            }
            .padding(AppSpacing.lg)
            .appScreen()
        }
    }
}

struct LoginSelectionView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Accesso")
                    .font(AppTypography.title)
                Text("Scegli l'area da aprire. Supabase gestisce login, ruoli e sessione.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                TrainerPlanSelectionView()
            } label: {
                AccessChoiceCard(title: "Sono un Personal Trainer", subtitle: "Scegli piano, registrati o accedi alla dashboard", icon: "person.crop.rectangle.stack")
            }

            NavigationLink {
                ClientAccessCodeView()
            } label: {
                AccessChoiceCard(title: "Sono un Cliente", subtitle: "Registrati con codice monouso o accedi con email", icon: "person.text.rectangle")
            }

            if AppConfiguration.isDemoLoginEnabled {
                SectionCard(title: "Demo sviluppo", icon: "hammer") {
                    VStack(spacing: AppSpacing.sm) {
                        SecondaryButton(title: "Entra come Trainer Demo", systemImage: "person.crop.rectangle") {
                            authViewModel.loginTrainerDemo()
                        }
                        SecondaryButton(title: "Entra come Cliente Demo", systemImage: "person") {
                            authViewModel.loginClientDemo()
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .navigationTitle("Login")
        .appScreen()
    }
}

private struct AccessChoiceCard: View {
    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(AppColors.accent)
                .frame(width: 46, height: 46)
                .background(AppColors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(AppColors.textSecondary)
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
                                .foregroundStyle(selectedPlan == plan.slug ? AppColors.success : AppColors.textSecondary)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(plan.name)
                                    .font(.headline)
                                Text(plan.description)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                                Text("\(plan.price) - \(plan.clients)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppColors.accent)
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
        .appScreen()
    }
}

struct TrainerRegistrationView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    let selectedPlanSlug: String

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            SectionCard(title: "Registrazione Trainer", icon: "person.badge.plus") {
                VStack(spacing: AppSpacing.md) {
                    TextField("Nome", text: $authViewModel.firstName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Cognome", text: $authViewModel.lastName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Nome attivita/studio", text: $authViewModel.businessName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Email", text: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    SecureField("Password", text: $authViewModel.password)
                        .textFieldStyle(.roundedBorder)

                    if let message = authViewModel.errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(AppColors.warning)
                    }

                    PrimaryButton(title: authViewModel.isLoading ? "Creo account..." : "Crea account trainer", systemImage: "checkmark.seal") {
                        authViewModel.selectedPlanSlug = selectedPlanSlug
                        authViewModel.registerTrainer()
                    }
                    .disabled(authViewModel.firstName.isEmpty || authViewModel.lastName.isEmpty || authViewModel.businessName.isEmpty)
                }
            }
            Spacer()
        }
        .padding(AppSpacing.lg)
        .navigationTitle("Registrazione")
        .appScreen()
    }
}

struct TrainerLoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            SectionCard(title: "Login Trainer", icon: "lock.shield") {
                VStack(spacing: AppSpacing.md) {
                    TextField("Email", text: $authViewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $authViewModel.password)
                        .textFieldStyle(.roundedBorder)

                    if let message = authViewModel.errorMessage {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(AppColors.warning)
                    }

                    PrimaryButton(title: authViewModel.isLoading ? "Accesso..." : "Entra come trainer", systemImage: "arrow.right.circle") {
                        authViewModel.loginTrainer()
                    }

                    if AppConfiguration.isDemoLoginEnabled {
                        SecondaryButton(title: "Entra come Trainer Demo", systemImage: "person.crop.rectangle") {
                            authViewModel.loginTrainerDemo()
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(AppSpacing.lg)
        .navigationTitle("Trainer")
        .appScreen()
    }
}

struct ClientAccessCodeView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                SectionCard(title: "Registrazione con codice", icon: "key.horizontal") {
                    VStack(spacing: AppSpacing.md) {
                        TextField("PT-XXXXXXXX", text: $authViewModel.accessCode)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .font(.system(.body, design: .monospaced))
                            .textFieldStyle(.roundedBorder)

                        TextField("Email", text: $authViewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)

                        SecureField("Password", text: $authViewModel.password)
                            .textFieldStyle(.roundedBorder)

                        if let message = authViewModel.errorMessage {
                            Text(message)
                                .font(.caption)
                                .foregroundStyle(AppColors.warning)
                        }

                        PrimaryButton(title: authViewModel.isLoading ? "Registro..." : "Registrati con codice", systemImage: "person.badge.plus") {
                            authViewModel.registerClientWithInviteCode()
                        }
                    }
                }

                SectionCard(title: "Login cliente", icon: "lock") {
                    VStack(spacing: AppSpacing.md) {
                        TextField("Email", text: $authViewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)

                        SecureField("Password", text: $authViewModel.password)
                            .textFieldStyle(.roundedBorder)

                        SecondaryButton(title: "Accedi con email", systemImage: "arrow.right.circle") {
                            authViewModel.loginClientWithEmail()
                        }
                    }
                }

                if AppConfiguration.isDemoLoginEnabled {
                    SecondaryButton(title: "Entra come Cliente Demo", systemImage: "person") {
                        authViewModel.loginClientDemo()
                    }
                }
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Cliente")
        .appScreen()
    }
}

struct ClientAccessCodeRegistrationView: View {
    var body: some View {
        ClientAccessCodeView()
    }
}
