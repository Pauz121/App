# TODO operativo

Data aggiornamento: 2026-05-17

## Da fare subito

- [ ] Build Xcode dopo aggiunta HealthKit.
- [ ] Applicare migration `20260517123000_daily_engagement_healthkit.sql` su Supabase.
- [ ] Testare consenso Apple Salute su iPhone reale.
- [ ] Testare RLS nuove tabelle con trainer A/B e cliente A/B.
- [ ] Aprire progetto su Mac e verificare build Xcode.
- [ ] Correggere eventuali errori Swift.
- [ ] Eseguire seed demo Supabase senza salvare credenziali.
- [ ] Verificare login trainer demo.
- [ ] Verificare login cliente demo.
- [ ] Implementare persistenza sessione in Keychain.
- [ ] Correggere mapping status appuntamenti.
- [ ] Correggere mapping status schede e nutrizione.
- [ ] Completare visualizzazione/generazione codice invito.
- [ ] Rimuovere `try?` critici dai flussi clienti/appuntamenti.

## Attivita per fase

### FASE 1 - Build e pulizia

- [ ] Build Debug su simulatore. Bloccata: serve Mac con Xcode.
- [ ] Avvio app. Bloccata: serve Mac con Xcode.
- [x] Navigazione auth verificata staticamente.
- [x] Verifica file nel target: tutti i 17 file Swift sono inclusi.
- [x] Decisione su view inutilizzate: `InviteCodeView` collegata al dettaglio cliente; `ClientAccessCodeRegistrationView` lasciata come wrapper non bloccante.

### FASE 2 - Auth e demo

- [ ] Seed demo Auth.
- [ ] Collegamento demo a `profiles`.
- [ ] Collegamento trainer a `trainers`.
- [ ] Collegamento cliente a `clients`.
- [ ] Restore session.
- [ ] Logout.
- [ ] Keychain.

### FASE 3 - Mapping status

- [ ] `AppointmentStatus` con valore DB inglese e label italiana.
- [ ] Status workout coerente con DB.
- [ ] Status nutrition coerente con DB.
- [ ] Rimozione `rawValue.lowercased()` rischiosi.

### FASE 4 - Clienti/inviti

- [ ] CRUD cliente reale.
- [ ] Generazione codice.
- [ ] Stato codice.
- [ ] Registrazione cliente.
- [ ] Revoca/scadenza.
- [ ] Limite piano.

### FASE 5 - Appuntamenti

- [ ] Create.
- [ ] Read trainer.
- [ ] Read cliente.
- [ ] Update.
- [ ] Delete.
- [ ] Dashboard aggiornate.

### FASE 6 - Schede

- [ ] DTO `workout_days`.
- [ ] DTO `exercises`.
- [ ] Lettura piano completo.
- [ ] Creazione da template.
- [ ] Creazione esercizi da catalogo.
- [ ] Area cliente con scheda completa.

### FASE 7 - Nutrizione

- [ ] DTO `meals`.
- [ ] DTO `meal_foods`.
- [ ] Lettura piano completo.
- [ ] Creazione da template.
- [ ] Creazione alimenti da catalogo.
- [ ] Area cliente con dieta completa.

### FASE 8 - Progressi/foto

- [ ] Photos picker.
- [ ] Upload Storage.
- [ ] Insert `progress_photos`.
- [ ] Lettura foto.
- [ ] Visualizzazione foto reale.
- [ ] Test privacy storage.

### FASE 8B - HealthKit e uso quotidiano

- [x] Modelli `DailyGoal`, `DailyStepSummary`, `DailyCheckIn`, `Streak`.
- [x] `HealthKitService` per disponibilita, autorizzazione, passi oggi, ultimi 7 giorni e media.
- [x] Servizi Supabase per check-in, obiettivi, riepiloghi attivita, streak e insight.
- [x] Dashboard cliente trasformata in "Oggi".
- [x] Sheet check-in giornaliero.
- [x] Card privacy/consenso Apple Salute.
- [x] Streak card.
- [x] Trainer insight "Clienti da seguire".
- [x] Migration nuove tabelle con RLS e grant.
- [ ] Build Xcode.
- [ ] Test iPhone reale HealthKit.
- [ ] Verifica RLS su Supabase remoto.

### FASE 9 - Cataloghi/template

- [ ] Picker catalogo macchine.
- [ ] Picker esercizi.
- [ ] Picker alimenti.
- [ ] Picker workout template.
- [ ] Picker meal template.

### FASE 10 - Sicurezza/RLS

- [ ] Test trainer A/B.
- [ ] Test cliente A/B.
- [ ] Test inviti.
- [ ] Test Storage privato.
- [ ] Revisione RPC `SECURITY DEFINER`.
- [ ] Advisor Supabase.

### FASE 11 - Errori/UX

- [ ] Loading state.
- [ ] Error state.
- [ ] Empty state.
- [ ] Retry.
- [ ] Validazione form.
- [ ] Feedback salvataggio.

### FASE 12 - SaaS

- [ ] Piano reale trainer.
- [ ] Trial residuo.
- [ ] Limite clienti UI.
- [ ] Upgrade plan.
- [ ] Scelta Stripe/IAP.
- [ ] Webhook/checkout sicuri.

### FASE 13 - Rilascio

- [ ] Test end-to-end.
- [ ] Device reale.
- [ ] TestFlight.
- [ ] Privacy policy.
- [ ] Termini servizio.
- [ ] App Store checklist.

## In corso

- [ ] FASE 1 in corso parziale: manca verifica reale su Xcode.
- [ ] Restyling UI in corso: manca verifica reale su Xcode/simulatore.

## Bloccate

- [ ] Verifica build bloccata finche non si usa un Mac con Xcode.
- [ ] Verifica avvio su simulatore bloccata finche non si usa un Mac con Xcode.

## Completate

- [x] Analisi tecnica iniziale.
- [x] Piano operativo documentato in BrainApp.
- [x] Audit statico target Xcode e sorgenti Swift.
- [x] Collegata `InviteCodeView` alla navigazione reale del dettaglio cliente.
- [x] Design system convertito a UI light moderna.
- [x] Componenti principali ridisegnati.
- [x] Dashboard trainer ridisegnata.
- [x] Calendario admin dinamico introdotto.
- [x] Dashboard cliente ridisegnata.
- [x] HealthKit, check-in giornaliero, obiettivi, streak e insight trainer implementati localmente.
