# Gestione Database Personal Trainer

Applicazione gestionale iOS nativa SwiftUI per la gestione SaaS di personal trainer, clienti, allenamenti, nutrizione, appuntamenti, macchinari e progressi.

## Apertura su Mac

1. Copia questa cartella su un Mac con Xcode installato.
2. Apri `GestioneDatabasePersonalTrainer.xcodeproj`.
3. In Xcode seleziona un simulatore iPhone oppure un iPhone reale.
4. In `Signing & Capabilities`, scegli il tuo Apple ID / Team.
5. Premi `Run`.

Il progetto usa dati mock in memoria e non richiede backend per l'avvio.

## Struttura

- `App/`: entry point e root navigation.
- `Models/`: modelli Codable del dominio.
- `MockData/`: database mock locale.
- `Services/`: servizi async pronti per backend reale.
- `ViewModels/`: stato schermate e logica MVVM.
- `Views/Auth/`: onboarding e login.
- `Views/Trainer/`: area personal trainer.
- `Views/Client/`: area cliente.
- `Views/Components/`: componenti riutilizzabili.
- `DesignSystem/`: colori, spacing, font, radius, stili.
- `Utilities/`: spazio predisposto per helper futuri.

## Backend futuro

Sostituisci le classi in `Services/` mantenendo le firme async. I ViewModel non dipendono dal tipo di storage: possono consumare Firebase, Supabase o API custom senza cambiare le schermate.

## Supabase

Il progetto ora include:

- `supabase/migrations/20260515120000_initial_saas_schema.sql`
- `supabase/migrations/20260515123000_harden_rpc_permissions.sql`
- `supabase/migrations/20260515124000_revoke_public_function_execute.sql`
- `supabase/migrations/20260515130000_catalog_schema.sql`
- `supabase/migrations/20260515131000_catalog_seed.sql`
- `supabase/seed_demo.js`

Le migration principali e catalogo sono gia state applicate al progetto Supabase `App Swift` (`ubjtnxwqrkxkttwlocfz`).

Cataloghi globali creati:

- `muscle_groups`
- `machine_catalog`
- `exercise_catalog`
- `food_catalog`
- `meal_templates`
- `meal_template_foods`
- `workout_templates`
- `workout_template_days`
- `workout_template_exercises`

Config iOS:

- `GestioneDatabasePersonalTrainer/Utilities/AppConfiguration.swift`

Demo login:

- Trainer: `demo.trainer@test.com` / `DemoTrainer123!`
- Cliente: `demo.cliente@test.com` / `DemoCliente123!`

Per creare gli account demo Auth e i dati collegati, usa una service role key solo sul tuo computer:

```bash
cd supabase
npm install
SUPABASE_URL=https://ubjtnxwqrkxkttwlocfz.supabase.co SUPABASE_SERVICE_ROLE_KEY=your-service-role-key npm run seed:demo
```

Non inserire mai la service role key nel codice iOS.
