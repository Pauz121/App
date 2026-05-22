import SwiftUI

@main
@MainActor
struct GestioneDatabasePersonalTrainerApp: App {
    @StateObject private var services: AppServices
    @StateObject private var authViewModel: AuthViewModel

    init() {
        let services = AppServices()
        _services = StateObject(wrappedValue: services)
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: services.authService))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(services)
                .environmentObject(authViewModel)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var services: AppServices
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch authViewModel.session {
            case .none:
                WelcomeView()
            case .trainer(let trainer):
                TrainerMainTabView(trainer: trainer)
            case .client(let client):
                ClientMainTabView(client: client)
            }
        }
        .tint(AppColors.accent)
        .task {
            authViewModel.restoreSession()
        }
    }
}
