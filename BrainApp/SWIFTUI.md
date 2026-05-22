# SwiftUI

Data aggiornamento: 2026-05-17

Aggiornamento Fase 1: audit statico completato. Tutti i file Swift sono nel target Xcode. `InviteCodeView` e ora usata in `ClientDetailView` per mostrare il codice invito esistente o appena generato.

Aggiornamento stile: creata scheda dedicata `BrainApp/STILE_APP.md` con descrizione di palette, tipografia, componenti, punti forti e punti deboli dello stile corrente.

Aggiornamento redesign UI: creata scheda dedicata `BrainApp/UI_REDESIGN.md`. L'app e stata portata verso una UI light moderna con design system aggiornato, bottoni neri, card leggere, dashboard trainer operativa, dashboard cliente piu personale e calendario admin dinamico.

## Struttura app

- `App/GestioneDatabasePersonalTrainerApp.swift`: entry point, `RootView`, injection `AppServices` e `AuthViewModel`.
- `Models/DomainModels.swift`: modelli dominio.
- `ViewModels/AuthViewModel.swift`: sessione, login, registrazione.
- `ViewModels/TrainerViewModels.swift`: dashboard trainer, clienti, appuntamenti, macchine, schede, nutrizione.
- `ViewModels/ClientViewModels.swift`: dashboard cliente, scheda, dieta, progressi.
- `Services/AppServices.swift`: service layer principale.
- `Services/SupabaseManager.swift`: REST client Supabase.
- `Services/SupabaseDTOs.swift`: DTO e mapper.
- `MockData/MockDatabase.swift`: fallback/dati demo locali.
- `Views/Auth/AuthViews.swift`: onboarding, login, registrazione.
- `Views/Trainer/TrainerViews.swift`: area trainer.
- `Views/Trainer/TrainerForms.swift`: form trainer.
- `Views/Client/ClientViews.swift`: area cliente.
- `Views/Components/Components.swift`: componenti riutilizzabili.
- `DesignSystem/DesignSystem.swift`: colori, font, spacing, stili.

## Navigazione

Root:

- nessuna sessione: `WelcomeView`
- sessione trainer: `TrainerMainTabView`
- sessione cliente: `ClientMainTabView`

Area trainer:

- Dashboard
- Clienti
- Agenda
- Macchine
- Schede
- Diete
- Piano

Area cliente:

- Home
- Profilo
- Scheda
- Dieta
- Progressi

## View principali

Auth:

- `WelcomeView`
- `LoginSelectionView`
- `TrainerPlanSelectionView`
- `TrainerRegistrationView`
- `TrainerLoginView`
- `ClientAccessCodeView`
- `ClientAccessCodeRegistrationView` wrapper non essenziale

Trainer:

- `TrainerDashboardView`
- `ClientsListView`
- `ClientDetailView`
- `InviteCodeView` collegata a `ClientDetailView`
- `AppointmentsCalendarView`
- `MachinesListView`
- `WorkoutPlansListView`
- `WorkoutPlanDetailView`
- `NutritionPlansListView`
- `NutritionPlanDetailView`
- `SubscriptionView`

Client:

- `ClientDashboardView`
- `ClientProfileView`
- `ClientWorkoutView`
- `ClientWorkoutDetailView`
- `ClientNutritionView`
- `ClientProgressView`
- `AddProgressEntryView`

## Problemi lato app

- Build non verificata su Xcode.
- Avvio non verificato su simulatore per assenza Mac/Xcode.
- Sessione in `UserDefaults`.
- Mapping enum/status errato verso DB.
- `try?` silenziosi in molti service.
- ViewModel spesso non espongono error/loading completi.
- Schede lette da Supabase senza giorni/esercizi.
- Diete lette da Supabase senza pasti/alimenti.
- Foto reali non visualizzate.
- `StorageService` non usato dalla UI.
- Cataloghi usati solo parzialmente.
- Demo dipende da seed assente.

## Direzione tecnica

- Mantenere MVVM.
- Mantenere il redesign come intervento frontend, senza riscrivere Supabase/Auth/service layer.
- Usare `DesignSystem.swift` come sorgente unica per palette, radius, typography e button styles.
- Differenziare visivamente trainer e cliente mantenendo tab view e navigazione esistenti.
- Separare gradualmente service grandi da `AppServices.swift` solo quando si toccano aree complesse.
- Aggiungere DTO mancanti prima di ampliare UI.
- Separare label UI italiana dai valori DB.
- Introdurre componenti comuni per error/loading/empty state.
- Collegare PhotosPicker solo quando Storage e `progress_photos` sono pronti.

## Redesign UI applicato

- `DesignSystem/DesignSystem.swift`: palette light, tipografia, radius, card leggere, button styles.
- `Views/Components/Components.swift`: componenti condivisi aggiornati e nuovi componenti per badge, quick actions, filtri e progress bar.
- `Views/Trainer/TrainerViews.swift`: dashboard trainer ridisegnata e calendario admin dinamico.
- `Views/Client/ClientViews.swift`: dashboard cliente ridisegnata con focus su allenamento, obiettivo, dieta e progressi.
- `App/GestioneDatabasePersonalTrainerApp.swift`: rimossa dark mode forzata.

## Test manuali minimi UI

- Avvio senza sessione.
- Login trainer.
- Login cliente.
- Logout.
- Creazione cliente.
- Generazione codice invito.
- Creazione appuntamento.
- Creazione scheda completa.
- Creazione dieta completa.
- Upload e visualizzazione foto progresso.
