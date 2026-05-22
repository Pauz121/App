# HealthKit e interattivita quotidiana

Data aggiornamento: 2026-05-17

## Obiettivo

Trasformare l'area cliente in una schermata "Oggi" utile ogni giorno: passi, obiettivi giornalieri, check-in, streak, piano attivo e progressi rapidi.

## Perche i passi aumentano l'uso quotidiano

I passi sono un dato semplice, comprensibile e aggiornabile durante la giornata. Collegarli a obiettivi, streak e insight trainer crea un motivo naturale per aprire l'app ogni giorno senza introdurre notifiche o missioni settimanali.

## Dati HealthKit letti

- Solo `stepCount`.
- Lettura passi di oggi.
- Lettura passi ultimi 7 giorni.
- Calcolo media settimanale.

Non vengono letti calorie, distanza, battito, sonno o dati sanitari complessi.

## Privacy e consenso

- L'accesso ai passi richiede consenso esplicito tramite Apple Salute.
- L'utente puo negare o revocare il consenso dalle impostazioni di Apple Salute.
- L'app salva solo riepiloghi giornalieri dei passi, non dati grezzi HealthKit.
- I dati non sono usati per diagnosi mediche.
- La UI mostra una card dedicata prima della richiesta permesso.

## Nuove tabelle Supabase

- `daily_checkins`
- `daily_goals`
- `client_activity_summaries`
- `client_streaks`

La migration `20260517123000_daily_engagement_healthkit.sql` abilita RLS, policy multi-tenant e grant `authenticated` per Data API.

## Nuovi service

- `HealthKitService`
- `DailyCheckInService`
- `DailyGoalsService`
- `ActivitySummaryService`
- `StreakService`
- `TrainerInsightsService`

## Nuove view SwiftUI

- `ProgressRingView`
- `StepsSummaryCard`
- `DailyGoalsView`
- `DailyGoalRowView`
- `DailyCheckInView`
- `DailyCheckInSheet`
- `StreakCard`
- `MetricMiniCard`
- `InsightCard`
- `TrainerClientInsightsView`
- `HealthPermissionView`

## Dashboard cliente aggiornata

`ClientDashboardView` diventa "Oggi" e include:

- header personale con data e frase breve;
- card passi con progress ring;
- obiettivi giornalieri interattivi;
- check-in giornaliero in sheet;
- streak;
- allenamento, dieta, prossimo appuntamento e progressi.

## Trainer insight

`TrainerDashboardView` mostra insight su:

- check-in mancanti;
- obiettivi passi raggiunti;
- clienti poco attivi;
- progressi/peso non aggiornati;
- streak rilevanti.

## Stato implementazione

Implementato nel codice locale:

- modelli Swift;
- servizi;
- view model;
- componenti UI;
- migration SQL;
- capability HealthKit e usage description;
- aggiornamento BrainApp.

## Prossimi step

- Applicare migration su Supabase e verificare RLS con utenti trainer/cliente reali.
- Build su Xcode.
- Test su iPhone reale per autorizzazione Apple Salute.
- Rifinire il completamento allenamento quando sara disponibile un log allenamenti persistente.
