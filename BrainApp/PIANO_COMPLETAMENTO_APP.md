# Piano completamento app - Gestione Database Personal Trainer

Data aggiornamento: 2026-05-17

Aggiornamento Fase 1: avviata in ambiente senza Mac. Completato audit statico di target e sorgenti; tutti i 17 file Swift sono inclusi nel progetto Xcode. Collegata `InviteCodeView` al dettaglio cliente. Restano bloccate build e prova avvio finche non sara disponibile Xcode.

## Stato attuale progetto

L'app e una SaaS iOS nativa SwiftUI per personal trainer collegata a Supabase tramite REST manuale. La UI e gia ampia e organizzata in MVVM, ma molte funzionalita sono solo parzialmente operative. Il backend Supabase esiste, ha schema operativo, cataloghi popolati, RLS e Storage privato, ma nel progetto remoto risultano assenti utenti Auth e dati operativi reali.

Percentuali stimate:

| Area | Completamento |
|---|---:|
| Generale | 35-40% |
| Frontend | 55% |
| Backend Supabase | 55% |
| Auth | 35% |
| Database | 65% |
| Sicurezza | 55% |
| SaaS | 35% |

## Criticita principali

1. Account demo mancanti nel Supabase reale.
2. Login demo non funzionante.
3. Mapping status appuntamenti errato: Swift usa valori italiani, Postgres vuole valori inglesi.
4. Mapping status schede/piani errato.
5. Schede incomplete: salva solo `workout_plans`, non `workout_days` ed `exercises`.
6. Nutrizione incompleta: salva solo `nutrition_plans`, non `meals` e `meal_foods`.
7. Foto progresso predisposte ma non operative.
8. `StorageService` non collegato alla UI.
9. `progress_photos` non viene popolata.
10. Errori Supabase spesso silenziati con `try?`.
11. Sessione salvata in `UserDefaults`, non Keychain.
12. Cataloghi/template letti superficialmente.
13. Template non copiati nelle tabelle operative.
14. Pagamenti SaaS assenti.
15. Build Xcode non verificata.
16. Alcune view inutilizzate o non collegate.
17. RPC `SECURITY DEFINER` da riesaminare.

## Roadmap operativa per fasi

### FASE 1 - Verifica build Xcode e pulizia progetto

Priorita: Alta

Obiettivo: ottenere una base compilabile e navigabile prima di toccare logica di prodotto.

Cosa fare:
- Aprire `GestioneDatabasePersonalTrainer.xcodeproj` su Mac con Xcode.
- Compilare target iOS su simulatore iPhone.
- Correggere errori Swift, import mancanti, warning bloccanti e problemi di deployment target.
- Verificare che tutti i file inclusi nel target siano presenti.
- Navigare da `WelcomeView` a login trainer/cliente e alle tab dopo login.
- Decidere se eliminare, collegare o lasciare come wrapper le view inutilizzate.

File da modificare:
- `GestioneDatabasePersonalTrainer.xcodeproj/project.pbxproj`
- `GestioneDatabasePersonalTrainer/App/GestioneDatabasePersonalTrainerApp.swift`
- `GestioneDatabasePersonalTrainer/Views/Auth/AuthViews.swift`
- `GestioneDatabasePersonalTrainer/Views/Trainer/TrainerViews.swift`
- `GestioneDatabasePersonalTrainer/Views/Client/ClientViews.swift`
- eventuali file con errori segnalati da Xcode

File da creare, se necessari:
- Nessuno obbligatorio.
- Eventuale `GestioneDatabasePersonalTrainerTests/` solo dopo build verde.

Tabelle Supabase coinvolte: nessuna.

Servizi coinvolti: `AppServices`, `AuthService`.

ViewModel coinvolti: `AuthViewModel`.

Schermate coinvolte: `WelcomeView`, `LoginSelectionView`, `TrainerMainTabView`, `ClientMainTabView`.

Errori da correggere:
- Errori compilazione Swift.
- File fuori target.
- View definite ma non navigabili se utili.

Criteri completamento:
- Build Debug iOS completata.
- App avviata su simulatore.
- Schermata iniziale visibile.
- Navigazione auth base funzionante.

Stato parziale 2026-05-17:
- Audit statico target completato.
- Navigazione base verificata da codice.
- `InviteCodeView` collegata.
- Build e avvio non verificabili senza Mac/Xcode.

Rischi tecnici:
- Differenze tra ambiente Windows e Xcode reale.
- Warning SwiftUI nascosti finche non si compila su Mac.

### FASE 2 - Sistemazione Auth e account demo

Priorita: Alta

Obiettivo: rendere reale e verificabile login, registrazione e sessione.

Cosa fare:
- Eseguire seed demo con service role key solo in ambiente locale sicuro.
- Creare utenti Auth demo trainer/cliente.
- Collegare demo a `profiles`, `trainers`, `clients`, `trainer_subscriptions`.
- Verificare `loginTrainer`, `loginClientWithEmail`, `registerTrainer`, `registerClientWithInviteCode`.
- Migrare persistenza sessione da `UserDefaults` a Keychain.
- Gestire refresh token o re-login pulito quando token scade.
- Separare credenziali demo da UI di produzione.

File da modificare:
- `Services/SupabaseManager.swift`
- `Services/AppServices.swift`
- `ViewModels/AuthViewModel.swift`
- `Views/Auth/AuthViews.swift`
- `supabase/seed_demo.js`
- `README.md`

File da creare, se necessari:
- `Utilities/KeychainStore.swift`
- eventuale `Services/AuthSessionStore.swift`

Tabelle Supabase coinvolte:
- `auth.users`, `profiles`, `trainers`, `trainer_subscriptions`, `subscription_plans`, `clients`, `client_invite_codes`

Servizi coinvolti:
- `SupabaseManager`, `AuthService`, `SubscriptionService`, `InviteCodeService`

ViewModel coinvolti:
- `AuthViewModel`

Schermate coinvolte:
- `TrainerLoginView`, `TrainerRegistrationView`, `ClientAccessCodeView`, `LoginSelectionView`

Errori da correggere:
- Demo assenti.
- Sessione salvata in `UserDefaults`.
- Errori Auth poco chiari.

Criteri completamento:
- Trainer demo entra in area trainer.
- Cliente demo entra in area cliente.
- Nuovo trainer si registra con trial.
- Cliente si registra con codice monouso valido.
- Logout pulisce sessione.
- Riapertura app ripristina sessione.

Rischi tecnici:
- Conferma email Supabase puo bloccare login.
- Token refresh assente puo rompere sessioni lunghe.
- Seed idempotente da verificare.

### FASE 3 - Correzione mapping enum/status

Priorita: Alta

Obiettivo: allineare i valori Swift ai vincoli PostgreSQL.

Cosa fare:
- Separare label UI italiana da valore DB inglese.
- Correggere mapping `AppointmentStatus`: `scheduled`, `completed`, `cancelled`.
- Correggere mapping piani: `active`, `archived`, `draft`.
- Evitare `rawValue.lowercased()` su enum con rawValue italiano.
- Aggiungere helper `dbValue` e init da DB.

File da modificare:
- `Models/DomainModels.swift`
- `Services/SupabaseDTOs.swift`
- `Services/AppServices.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Components/Components.swift`

File da creare, se necessari:
- Nessuno obbligatorio.

Tabelle Supabase coinvolte:
- `appointments`, `workout_plans`, `nutrition_plans`

Servizi coinvolti:
- `AppointmentService`, `WorkoutService`, `NutritionService`, `SupabaseMapper`

ViewModel coinvolti:
- `AppointmentsViewModel`, `WorkoutPlansViewModel`, `NutritionPlansViewModel`, `ClientWorkoutViewModel`, `ClientNutritionViewModel`

Schermate coinvolte:
- `AppointmentsCalendarView`, `AddAppointmentView`, `WorkoutPlansListView`, `NutritionPlansListView`, viste cliente scheda/dieta

Errori da correggere:
- Insert appuntamenti con status italiano.
- Insert schede con status italiano.

Criteri completamento:
- Insert/update appuntamento non viola check DB.
- Insert scheda/nutrizione non viola check DB.
- UI continua a mostrare label italiane.

Rischi tecnici:
- Dati esistenti eventualmente salvati con valori errati da bonificare.

### FASE 4 - CRUD completo clienti e codici invito

Priorita: Alta

Obiettivo: rendere operativo il ciclo trainer crea cliente, genera codice, cliente si registra.

Cosa fare:
- Completare creazione cliente su Supabase con validazioni.
- Generare codice monouso solo dopo cliente persistito.
- Mostrare codice in dettaglio cliente usando `InviteCodeView` o UI equivalente.
- Visualizzare stato codice: attivo, usato, scaduto, revocato.
- Gestire scadenza e revoca lato UI.
- Evitare fallback silenziosi quando Supabase fallisce.
- Bloccare creazione cliente se limite piano superato.

File da modificare:
- `Services/AppServices.swift`
- `Services/SupabaseDTOs.swift`
- `ViewModels/TrainerViewModels.swift`
- `Views/Trainer/TrainerViews.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Auth/AuthViews.swift`

File da creare, se necessari:
- `Models/InviteCodeModels.swift` oppure DTO in `SupabaseDTOs.swift`
- eventuale `ViewModels/InviteCodeViewModel.swift`

Tabelle Supabase coinvolte:
- `clients`, `client_invite_codes`, `profiles`, `trainers`, `trainer_subscriptions`, `subscription_plans`, `app_audit_logs`

Servizi coinvolti:
- `ClientService`, `InviteCodeService`, `SubscriptionService`, `AuthService`

ViewModel coinvolti:
- `ClientsViewModel`, `AuthViewModel`

Schermate coinvolte:
- `ClientsListView`, `ClientDetailView`, `AddClientView`, `ClientAccessCodeView`, `InviteCodeView`

Errori da correggere:
- Codice non mostrato dopo generazione.
- Errori insert cliente nascosti.
- Nessun feedback su codice scaduto/usato.

Criteri completamento:
- Trainer crea cliente.
- Trainer genera codice.
- Cliente usa codice una sola volta.
- Codice usato non riutilizzabile.
- Codice scaduto produce errore chiaro.

Rischi tecnici:
- Race condition su codice gia usato.
- Policy RLS troppo restrittive o troppo permissive.

### FASE 5 - Appuntamenti reali

Priorita: Alta

Obiettivo: rendere affidabile agenda trainer/cliente.

Cosa fare:
- Completare CRUD appuntamenti con mapping corretto.
- Validare cliente selezionato, inizio/fine e status.
- Mostrare appuntamenti in dashboard trainer.
- Mostrare prossima sessione in dashboard cliente.
- Gestire edit/delete con feedback.

File da modificare:
- `Services/AppServices.swift`
- `Services/SupabaseDTOs.swift`
- `ViewModels/TrainerViewModels.swift`
- `ViewModels/ClientViewModels.swift`
- `Views/Trainer/TrainerViews.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Client/ClientViews.swift`
- `Views/Components/Components.swift`

File da creare, se necessari:
- Nessuno obbligatorio.

Tabelle Supabase coinvolte:
- `appointments`, `clients`, `trainers`

Servizi coinvolti:
- `AppointmentService`, `ClientService`

ViewModel coinvolti:
- `AppointmentsViewModel`, `TrainerDashboardViewModel`, `ClientDashboardViewModel`

Schermate coinvolte:
- `AppointmentsCalendarView`, `AddAppointmentView`, `TrainerDashboardView`, `ClientDashboardView`

Errori da correggere:
- Status errato.
- Errori delete/update silenziati.

Criteri completamento:
- Creazione, modifica, completamento, cancellazione appuntamenti funzionano.
- Trainer vede solo propri appuntamenti.
- Cliente vede solo propri appuntamenti.

Rischi tecnici:
- Timezone e date ISO8601.
- Ordinamento lato Supabase.

### FASE 6 - Schede allenamento complete

Priorita: Alta

Obiettivo: salvare, leggere e mostrare schede complete con giorni ed esercizi.

Cosa fare:
- Aggiungere DTO per `workout_days` ed `exercises`.
- Implementare insert transazionale o sequenziale robusto: piano, giorni, esercizi.
- Leggere scheda completa con query annidate o chiamate coordinate.
- Usare `exercise_catalog` nei picker.
- Usare `workout_templates`, `workout_template_days`, `workout_template_exercises`.
- Copiare template nelle tabelle operative.
- Mostrare scheda completa in area cliente.
- Gestire completamento allenamento, se richiesto, con tabella futura o stato locale esplicito.

File da modificare:
- `Models/DomainModels.swift`
- `Services/SupabaseDTOs.swift`
- `Services/AppServices.swift`
- `ViewModels/TrainerViewModels.swift`
- `ViewModels/ClientViewModels.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Trainer/TrainerViews.swift`
- `Views/Client/ClientViews.swift`
- `Views/Components/Components.swift`

File da creare, se necessari:
- `Services/WorkoutService.swift` se si separa da `AppServices.swift`
- `ViewModels/WorkoutTemplatePickerViewModel.swift`
- eventuale migration per tracking completamento workout se necessario

Tabelle Supabase coinvolte:
- `workout_plans`, `workout_days`, `exercises`, `exercise_catalog`, `workout_templates`, `workout_template_days`, `workout_template_exercises`, `machines`, `clients`, `trainers`

Servizi coinvolti:
- `WorkoutService`, `CatalogService`, `MachineService`

ViewModel coinvolti:
- `WorkoutPlansViewModel`, `ClientWorkoutViewModel`, `ClientDashboardViewModel`

Schermate coinvolte:
- `CreateWorkoutPlanView`, `WorkoutPlansListView`, `WorkoutPlanDetailView`, `ClientWorkoutView`, `ClientWorkoutDetailView`

Errori da correggere:
- `days: []` quando si legge da Supabase.
- Template selezionato non copiato.
- Esercizi hardcoded invece di catalogo.

Criteri completamento:
- Trainer crea scheda da zero o da template.
- DB contiene piano, giorni, esercizi.
- Cliente vede giorni ed esercizi reali.
- RLS impedisce accesso a schede altrui.

Rischi tecnici:
- Mancanza transazioni lato REST.
- Query annidate PostgREST da tipizzare con cura.

### FASE 7 - Piani nutrizionali completi

Priorita: Alta

Obiettivo: salvare e leggere dieta completa con pasti e alimenti.

Cosa fare:
- Aggiungere DTO per `meals`, `meal_foods`, template dettaglio.
- Salvare `nutrition_plans`, `meals`, `meal_foods`.
- Leggere piano completo.
- Usare `food_catalog` nei picker.
- Usare `meal_templates` e `meal_template_foods`.
- Copiare template nelle tabelle operative.
- Mostrare dieta completa al cliente.

File da modificare:
- `Models/DomainModels.swift`
- `Services/SupabaseDTOs.swift`
- `Services/AppServices.swift`
- `ViewModels/TrainerViewModels.swift`
- `ViewModels/ClientViewModels.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Trainer/TrainerViews.swift`
- `Views/Client/ClientViews.swift`
- `Views/Components/Components.swift`

File da creare, se necessari:
- `Services/NutritionService.swift` se si separa da `AppServices.swift`
- `ViewModels/FoodPickerViewModel.swift`
- `Views/Trainer/FoodPickerView.swift`

Tabelle Supabase coinvolte:
- `nutrition_plans`, `meals`, `meal_foods`, `food_catalog`, `meal_templates`, `meal_template_foods`, `clients`, `trainers`

Servizi coinvolti:
- `NutritionService`, `CatalogService`

ViewModel coinvolti:
- `NutritionPlansViewModel`, `ClientNutritionViewModel`, `ClientDashboardViewModel`

Schermate coinvolte:
- `CreateNutritionPlanView`, `NutritionPlansListView`, `NutritionPlanDetailView`, `ClientNutritionView`

Errori da correggere:
- `meals: []` quando si legge da Supabase.
- Template pasti non copiati.
- Alimenti catalogo solo conteggiati, non usati.

Criteri completamento:
- Trainer crea piano completo.
- DB contiene piano, pasti, alimenti.
- Cliente vede dieta reale.

Rischi tecnici:
- Modellazione macro/calorie incompleta.
- Validazioni nutrizionali da mantenere semplici.

### FASE 8 - Progressi e foto

Priorita: Alta

Obiettivo: rendere operativi progressi, upload immagini e visualizzazione foto.

Cosa fare:
- Collegare `PhotosPicker` o camera/photo library in `AddProgressEntryView`.
- Usare `StorageService.uploadProgressPhoto`.
- Dopo upload, inserire record in `progress_photos`.
- Leggere foto associate a `progress_entries`.
- Mostrare immagini reali tramite signed URL o download autenticato.
- Permettere upload cliente.
- Permettere visualizzazione trainer.
- Gestire privacy e cancellazione.

File da modificare:
- `Services/SupabaseManager.swift`
- `Services/AppServices.swift`
- `Services/SupabaseDTOs.swift`
- `Models/DomainModels.swift`
- `ViewModels/ClientViewModels.swift`
- `Views/Client/ClientViews.swift`
- `Views/Components/Components.swift`

File da creare, se necessari:
- `Services/ProgressPhotoService.swift`
- `Models/ProgressPhoto.swift`
- `Views/Components/RemoteProgressImageView.swift`

Tabelle Supabase coinvolte:
- `progress_entries`, `progress_photos`, `clients`, `trainers`, `storage.objects`

Servizi coinvolti:
- `ProgressService`, `StorageService`, `SupabaseManager`

ViewModel coinvolti:
- `ClientProgressViewModel`, `ClientDashboardViewModel`, eventuale trainer progress view futura

Schermate coinvolte:
- `ClientProgressView`, `AddProgressEntryView`, `ClientDashboardView`, eventuale `ClientDetailView`

Errori da correggere:
- UI placeholder.
- `progress_photos` non popolata.
- Nessun signed URL/download.

Criteri completamento:
- Cliente carica foto fronte/lato/retro.
- Storage contiene oggetti nel path corretto.
- `progress_photos` contiene metadata.
- Trainer vede foto dei propri clienti.
- Utente non autorizzato non vede foto.

Rischi tecnici:
- Policy Storage basate su path UUID: path errato blocca accesso.
- Compressione immagini e dimensioni file.

### FASE 9 - Cataloghi e template

Priorita: Media

Obiettivo: trasformare cataloghi da semplice lettura a strumenti operativi.

Cosa fare:
- Creare picker riutilizzabili per esercizi, macchine, alimenti, template.
- Collegare `machine_catalog` alla creazione macchinari.
- Collegare `exercise_catalog` alla creazione esercizi.
- Collegare `food_catalog` alla creazione alimenti piano.
- Collegare template workout/nutrizione alla copia operativa.
- Evitare dati finti hardcoded nelle tabelle operative.

File da modificare:
- `Services/AppServices.swift`
- `Services/SupabaseDTOs.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Trainer/TrainerViews.swift`
- `ViewModels/TrainerViewModels.swift`

File da creare, se necessari:
- `Views/Catalog/CatalogPickerViews.swift`
- `ViewModels/CatalogViewModels.swift`
- `Services/CatalogService.swift` se separato

Tabelle Supabase coinvolte:
- `machine_catalog`, `exercise_catalog`, `food_catalog`, `meal_templates`, `meal_template_foods`, `workout_templates`, `workout_template_days`, `workout_template_exercises`

Servizi coinvolti:
- `CatalogService`, `WorkoutService`, `NutritionService`, `MachineService`

ViewModel coinvolti:
- `MachinesViewModel`, `WorkoutPlansViewModel`, `NutritionPlansViewModel`

Schermate coinvolte:
- `AddMachineView`, `CreateWorkoutPlanView`, `CreateNutritionPlanView`

Errori da correggere:
- Cataloghi usati solo per conteggi o autofill superficiale.

Criteri completamento:
- Trainer seleziona cataloghi/template e genera dati operativi puliti.

Rischi tecnici:
- UI troppo complessa se si prova a completare tutto in una singola schermata.

### FASE 10 - Sicurezza e RLS

Priorita: Alta

Obiettivo: verificare isolamento dati e ridurre rischi Supabase.

Cosa fare:
- Testare end-to-end RLS con due trainer e due clienti.
- Verificare visibilita dati trainer/cliente.
- Verificare codici invito usati/scaduti.
- Verificare bucket privato.
- Riesaminare RPC `SECURITY DEFINER`.
- Spostare funzioni helper non chiamate dal client fuori schema pubblico o revocare execute se non servono.
- Correggere warning performance critici: FK senza indici, auth initplan, policy multiple permissive se necessario.

File da modificare:
- `supabase/migrations/*.sql`
- `Services/AppServices.swift` solo se cambiano RPC o query
- documentazione `BrainApp/SUPABASE.md`

File da creare, se necessari:
- Nuove migration Supabase.
- Script test RLS locale o SQL di verifica.

Tabelle Supabase coinvolte:
- Tutte le operative e catalogo, `storage.objects`.

Servizi coinvolti:
- Tutti i service che leggono/scrivono Supabase.

ViewModel coinvolti:
- Indirettamente tutti.

Schermate coinvolte:
- Trainer e cliente complete.

Errori da correggere:
- RPC `SECURITY DEFINER` esposte oltre il necessario.
- Performance lints sugli indici e RLS.

Criteri completamento:
- Trainer A non vede dati Trainer B.
- Cliente A non vede dati Cliente B.
- Storage privato non espone file ad altri utenti.
- Advisor security senza warning critici non intenzionali.

Rischi tecnici:
- Correggere RPC puo rompere flussi Auth/invito.

### FASE 11 - Gestione errori e UX reale

Priorita: Alta

Obiettivo: eliminare fallimenti silenziosi e dare feedback affidabile.

Cosa fare:
- Rimuovere `try?` dove nasconde errori utente.
- Propagare errori dai service ai ViewModel.
- Aggiungere stati `isLoading`, `errorMessage`, `successMessage`.
- Mostrare alert/toast/inline error.
- Validare form prima delle chiamate.
- Aggiungere retry su caricamenti.
- Empty state coerenti per liste vuote reali.

File da modificare:
- `Services/AppServices.swift`
- `ViewModels/AuthViewModel.swift`
- `ViewModels/TrainerViewModels.swift`
- `ViewModels/ClientViewModels.swift`
- `Views/Auth/AuthViews.swift`
- `Views/Trainer/TrainerViews.swift`
- `Views/Trainer/TrainerForms.swift`
- `Views/Client/ClientViews.swift`
- `Views/Components/Components.swift`

File da creare, se necessari:
- `Models/AppErrorState.swift`
- `Views/Components/ErrorBannerView.swift`
- `Views/Components/LoadingStateView.swift`

Tabelle Supabase coinvolte:
- Tutte indirettamente.

Servizi coinvolti:
- Tutti.

ViewModel coinvolti:
- Tutti.

Schermate coinvolte:
- Tutte le schermate operative.

Errori da correggere:
- `try?` silenziosi.
- Salvataggi che sembrano riusciti ma non persistono.

Criteri completamento:
- Ogni azione critica mostra loading.
- Ogni errore Supabase rilevante arriva all'utente.
- Nessun salvataggio fallito viene presentato come riuscito.

Rischi tecnici:
- Cambiare firme async puo toccare molte view.

### FASE 12 - Abbonamenti SaaS

Priorita: Media

Obiettivo: completare trial, limiti e upgrade piano.

Cosa fare:
- Mostrare piano corrente reale da `trainer_subscriptions`.
- Mostrare scadenza trial.
- Bloccare creazione cliente oltre limite.
- Creare schermata upgrade piano.
- Decidere pagamenti: per App Store, se il contenuto/servizio digitale e consumato nell'app, valutare Apple In-App Purchase; per servizi one-to-one reali di personal training gestiti fuori app, Stripe puo essere praticabile ma va verificato con linee guida App Store.
- Predisporre provider senza inserire chiavi nell'app.
- Salvare `provider` e `provider_subscription_id` lato backend.

File da modificare:
- `Services/AppServices.swift`
- `Services/SupabaseDTOs.swift`
- `ViewModels/TrainerViewModels.swift`
- `Views/Trainer/TrainerViews.swift`
- `Views/Auth/AuthViews.swift`

File da creare, se necessari:
- `Services/BillingService.swift`
- `ViewModels/SubscriptionViewModel.swift`
- eventuali Edge Functions Supabase per checkout/webhook

Tabelle Supabase coinvolte:
- `subscription_plans`, `trainer_subscriptions`, `trainers`, `clients`, `app_audit_logs`

Servizi coinvolti:
- `SubscriptionService`, futuro `BillingService`, `ClientService`

ViewModel coinvolti:
- `ClientsViewModel`, futuro `SubscriptionViewModel`, `AuthViewModel`

Schermate coinvolte:
- `SubscriptionView`, `TrainerPlanSelectionView`, `AddClientView`

Errori da correggere:
- Piano locale hardcoded `.pro`.
- Nessun blocco UI se limite superato.

Criteri completamento:
- Trainer vede piano reale.
- Trial mostra giorni residui.
- Limite clienti applicato lato DB e UI.
- Flusso upgrade progettato e prototipato.

Rischi tecnici:
- Scelta Stripe/IAP impatta approvazione App Store.
- Pagamenti richiedono backend sicuro.

### FASE 13 - Test finale e preparazione App Store

Priorita: Media

Obiettivo: validare prodotto end-to-end e preparare distribuzione.

Cosa fare:
- Testare login, registrazioni, CRUD clienti, appuntamenti, schede, dieta, foto.
- Testare RLS con utenti multipli.
- Testare su device reale.
- Configurare TestFlight.
- Preparare privacy policy e termini.
- Verificare permessi foto/camera in Info.plist.
- Verificare App Store metadata, screenshot, categoria, support URL.
- Verificare gestione dati sanitari/fitness e privacy.

File da modificare:
- `GestioneDatabasePersonalTrainer.xcodeproj/project.pbxproj`
- eventuali Info.plist generati via build settings
- `README.md`
- documentazione `BrainApp/*`

File da creare, se necessari:
- Test suite UI/unit.
- Documenti privacy/terms fuori dal codice o in repository documentale.

Tabelle Supabase coinvolte:
- Tutte.

Servizi coinvolti:
- Tutti.

ViewModel coinvolti:
- Tutti.

Schermate coinvolte:
- Tutte.

Errori da correggere:
- Crash, regressioni UI, problemi permessi, RLS, storage.

Criteri completamento:
- Scenario trainer completo funziona.
- Scenario cliente completo funziona.
- TestFlight installabile.
- Nessun accesso cross-tenant.
- Privacy/App Store checklist completa.

Rischi tecnici:
- Review App Store su pagamenti e dati salute.
- Permessi foto/camera mancanti.

## Tabella priorita

| Fase | Urgenza | Complessita | Impatto | Ordine |
|---|---|---|---|---:|
| 1 Build e pulizia | Alta | Media | Alto | 1 |
| 2 Auth e demo | Alta | Alta | Alto | 2 |
| 3 Mapping enum/status | Alta | Bassa | Alto | 3 |
| 4 Clienti e inviti | Alta | Media | Alto | 4 |
| 5 Appuntamenti | Alta | Media | Alto | 5 |
| 6 Schede complete | Alta | Alta | Alto | 6 |
| 7 Nutrizione completa | Alta | Alta | Alto | 7 |
| 8 Progressi e foto | Alta | Alta | Alto | 8 |
| 10 Sicurezza e RLS | Alta | Alta | Alto | 9 |
| 11 Errori e UX | Alta | Media | Alto | 10 |
| 9 Cataloghi e template | Media | Media | Medio-Alto | 11 |
| 12 Abbonamenti SaaS | Media | Alta | Alto | 12 |
| 13 Test/App Store | Media | Alta | Alto | 13 |

## Prime 10 attivita da fare subito

1. Aprire il progetto su Mac e ottenere build Xcode verde.
2. Eseguire/validare seed demo Supabase senza salvare credenziali nel repository.
3. Confermare login trainer demo e cliente demo.
4. Implementare Keychain per sessione Auth.
5. Correggere mapping `AppointmentStatus`.
6. Correggere mapping status `WorkoutPlan` e `NutritionPlan`.
7. Rimuovere i primi `try?` critici da clienti/appuntamenti.
8. Completare generazione e visualizzazione codice invito.
9. Verificare creazione cliente reale e registrazione cliente con codice.
10. Testare RLS minimo: trainer vede solo i propri clienti.

## Cosa testare dopo ogni fase

| Fase | Test minimo |
|---|---|
| 1 | Build, avvio, navigazione auth/tab |
| 2 | Login demo, registrazione trainer, registrazione cliente, restore/logout |
| 3 | Insert/update appuntamento e piano senza errori check DB |
| 4 | Crea cliente, genera codice, registra cliente, codice non riutilizzabile |
| 5 | CRUD appuntamenti trainer e visualizzazione cliente |
| 6 | Crea scheda completa, cliente vede giorni/esercizi |
| 7 | Crea dieta completa, cliente vede pasti/alimenti |
| 8 | Upload foto, metadata salvato, visualizzazione autorizzata |
| 9 | Picker cataloghi/template generano dati operativi |
| 10 | Test cross-tenant negativo e Storage privato |
| 11 | Errori visibili, loading, retry, validazioni |
| 12 | Trial, limite clienti, piano reale, upgrade predisposto |
| 13 | Scenario completo su device/TestFlight |

## Stima realistica lavoro rimanente

Stima per arrivare a MVP utilizzabile da un trainer reale: 4-7 settimane di lavoro concentrato.

Stima per App Store/TestFlight robusto con pagamenti, privacy e test cross-tenant: 8-12 settimane.

Driver principali di complessita:
- Schede e dieta complete con tabelle figlie.
- Storage foto e permessi.
- Sicurezza RLS end-to-end.
- Pagamenti e compliance App Store.

## Rischi principali

- Build non ancora verificata su Xcode.
- REST manuale Supabase puo diventare fragile con query annidate complesse.
- Sessione Auth senza refresh token robusto.
- RLS funziona sulla carta ma va testata con piu utenti reali.
- Pagamenti possono richiedere Apple IAP invece di Stripe a seconda del modello commerciale.
- Foto progresso sono dati sensibili: privacy, storage privato e accesso devono essere verificati bene.

## Ordine preciso consigliato

1. Build Xcode.
2. Seed demo e Auth reale.
3. Mapping enum/status.
4. CRUD clienti + inviti.
5. Appuntamenti.
6. Schede complete.
7. Diete complete.
8. Progressi + foto.
9. Sicurezza/RLS.
10. Gestione errori e UX.
11. Cataloghi/template avanzati.
12. Abbonamenti/pagamenti.
13. TestFlight/App Store.

## Note finali

Il progetto ha gia una buona base UI e uno schema Supabase serio. Il lavoro piu importante non e aggiungere nuove schermate, ma rendere reali, persistenti, verificabili e sicuri i flussi gia disegnati.
