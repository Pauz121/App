# Stato progetto - Gestione Database Personal Trainer

Data aggiornamento: 2026-05-17

## Stato attuale app

App iOS SwiftUI SaaS per personal trainer, strutturata in MVVM e collegata a Supabase via REST manuale. Il progetto contiene UI trainer, UI cliente, Auth, servizi, modelli, mock data e migration Supabase.

Aggiornamento Fase 1: eseguito audit statico del progetto in ambiente Windows. Tutti i 17 file Swift presenti sul disco risultano inclusi nel target Xcode. La build e l'avvio restano non verificabili senza Mac/Xcode. `InviteCodeView` e stata collegata al dettaglio cliente per ridurre codice UI inutilizzato.

## Percentuali

| Area | Stato |
|---|---:|
| Generale | 35-40% |
| Frontend | 55% |
| Backend Supabase | 55% |
| Auth | 35% |
| Database | 65% |
| Sicurezza | 55% |
| SaaS | 35% |

## Cosa funziona o e presente

- UI SwiftUI abbastanza completa.
- Navigazione separata trainer/cliente.
- Navigazione base verificata staticamente da `RootView` verso aree trainer/cliente.
- MVVM con service layer.
- Supabase configurato.
- Schema operativo creato.
- Cataloghi globali creati e popolati.
- RLS e policy presenti.
- Bucket privato `progress-photos` presente.
- RPC principali presenti.
- CRUD base teorico per clienti, appuntamenti, macchinari e progressi.
- Piani SaaS presenti.

## Cosa e mock o parziale

- MockDatabase ancora usato come fallback o sorgente dati in alcune aree.
- Demo login non funziona nel Supabase reale per assenza utenti Auth.
- Schede salvano solo piano principale.
- Diete salvano solo piano principale.
- Foto progresso solo placeholder.
- Template/cataloghi usati superficialmente.
- Errori Supabase spesso silenziati.

## Cosa manca

- Build Xcode verificata.
- Avvio su simulatore verificato.
- Account demo reali.
- Keychain per sessione.
- Mapping enum DB corretto.
- CRUD completo tabelle figlie schede/diete.
- Upload foto e `progress_photos`.
- UX errori/loading/retry.
- Test RLS end-to-end.
- Pagamenti SaaS.
- TestFlight/App Store readiness.

## Stato Supabase remoto

- Progetto Supabase: attivo e sano.
- Tabelle operative: presenti ma vuote.
- Auth users: vuoto al momento dell'analisi.
- Cataloghi: popolati.
- Storage: bucket privato presente.

## Nota credenziali

Non salvare nel vault chiavi reali, service role key, password o token. Usare placeholder:

- `SUPABASE_URL=...`
- `SUPABASE_ANON_KEY=...`
- `SERVICE_ROLE_KEY=NON_INSERIRE_NEL_VAULT`
