# Supabase

Data aggiornamento: 2026-05-17

## Configurazione

Il progetto iOS punta a Supabase tramite `AppConfiguration.swift`.

Non salvare credenziali reali nel vault.

Placeholder ammessi:

- `SUPABASE_URL=...`
- `SUPABASE_ANON_KEY=...`
- `SERVICE_ROLE_KEY=NON_INSERIRE_NEL_VAULT`

## Stato remoto noto

- Progetto Supabase attivo.
- Database Postgres attivo.
- Tabelle operative presenti ma vuote al momento dell'analisi.
- Cataloghi popolati.
- Auth users vuoto al momento dell'analisi.
- Bucket `progress-photos` presente e privato.

## Tabelle operative

- `profiles`: profili utente e ruolo.
- `trainers`: dati trainer/studio.
- `trainer_subscriptions`: abbonamenti trainer.
- `subscription_plans`: piani SaaS.
- `clients`: clienti del trainer.
- `client_invite_codes`: codici invito monouso.
- `appointments`: appuntamenti.
- `machines`: macchinari del trainer.
- `workout_plans`: piano scheda.
- `workout_days`: giorni scheda.
- `exercises`: esercizi assegnati.
- `nutrition_plans`: piano nutrizione.
- `meals`: pasti.
- `meal_foods`: alimenti del pasto.
- `progress_entries`: misure progressi.
- `progress_photos`: metadata foto.
- `app_audit_logs`: audit.

## Tabelle catalogo

- `muscle_groups`
- `machine_catalog`
- `exercise_catalog`
- `food_catalog`
- `meal_templates`
- `meal_template_foods`
- `workout_templates`
- `workout_template_days`
- `workout_template_exercises`

## RPC presenti

- `create_trainer_account`
- `generate_client_invite_code`
- `redeem_client_invite_code`
- `trainer_can_add_client`
- `get_current_trainer_id`
- `get_current_client_id`
- `is_current_trainer`
- `is_super_admin`
- `trainer_owns_client`

## RLS

RLS e abilitata sulle tabelle pubbliche operative e catalogo. Le policy separano dati trainer/cliente e permettono lettura cataloghi agli utenti autenticati.

Da verificare:

- Trainer A non vede clienti di Trainer B.
- Cliente vede solo i propri dati.
- Trainer vede foto solo dei propri clienti.
- Codice invito non e leggibile/usabile da altri trainer.
- RPC `SECURITY DEFINER` esposte solo dove necessario.

## Storage

Bucket:

- `progress-photos`
- privato: si
- path previsto: `trainerID/clientID/progressEntryID/photoType_uuid.jpg`

Da completare nell'app:

- Upload da UI.
- Insert in `progress_photos`.
- Lettura foto con signed URL o download autenticato.
- Cancellazione foto e metadata.

## Problemi Supabase da risolvere

- Account demo assenti.
- Tabelle operative vuote.
- Warning advisor su RPC `SECURITY DEFINER`.
- Warning performance: FK non indicizzate, policy multiple permissive, auth initplan.
- Mapping status Swift/Postgres non allineato.
- Query complete per tabelle figlie non implementate.
- Errori REST spesso ignorati lato app.

## Note sicurezza

- Non usare `user_metadata` per autorizzazione RLS.
- Non esporre service role key nel client.
- Conservare token in Keychain lato iOS.
- Testare RLS con utenti reali multipli prima di TestFlight pubblico.
