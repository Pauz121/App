# Roadmap sintetica

Data aggiornamento: 2026-05-17

## Ordine consigliato

1. FASE 1 - Build Xcode e pulizia progetto.
2. FASE 2 - Auth reale, account demo e Keychain.
3. FASE 3 - Mapping enum/status.
4. FASE 4 - Clienti e codici invito.
5. FASE 5 - Appuntamenti reali.
6. FASE 6 - Schede allenamento complete.
7. FASE 7 - Piani nutrizionali completi.
8. FASE 8 - Progressi e foto.
9. FASE 8B - HealthKit, check-in giornaliero, obiettivi e streak.
10. FASE 10 - Sicurezza e RLS.
11. FASE 11 - Gestione errori e UX reale.
12. FASE 9 - Cataloghi e template avanzati.
13. FASE 12 - Abbonamenti SaaS.
14. FASE 13 - Test finale e App Store.

## Priorita

| Fase | Priorita | Motivo |
|---|---|---|
| 1 | Alta | Senza build verde non si puo validare nulla |
| 2 | Alta | Auth e demo rendono testabile il prodotto |
| 3 | Alta | Mapping errato blocca insert/update reali |
| 4 | Alta | Clienti e inviti sono il cuore SaaS |
| 5 | Alta | Agenda e dashboard dipendono dagli appuntamenti |
| 6 | Alta | Schede sono feature core per trainer |
| 7 | Alta | Nutrizione e feature core richiesta |
| 8 | Alta | Progressi/foto sono dati sensibili e distintivi |
| 8B | Alta | Passi, check-in e streak aumentano uso quotidiano e insight trainer |
| 10 | Alta | Multi-tenant senza RLS verificata non e sicuro |
| 11 | Alta | Errori silenziosi rendono il prodotto inaffidabile |
| 9 | Media | Migliora produttivita trainer |
| 12 | Media | Necessario per SaaS commerciale |
| 13 | Media | Necessario per rilascio |

## Milestone

### Milestone A - App testabile

Include fasi 1, 2, 3. Risultato: build verde, login reale, mapping DB corretto.

### Milestone B - MVP operativo trainer/cliente

Include fasi 4, 5, 6, 7. Risultato: trainer gestisce clienti, appuntamenti, schede e dieta reali.

### Milestone C - Prodotto sicuro e usabile

Include fasi 8, 10, 11. Risultato: progressi con foto, RLS verificata, UX errori reale.

### Milestone C2 - Uso quotidiano cliente

Include fase 8B. Risultato: dashboard cliente "Oggi", passi HealthKit, check-in, obiettivi, streak e insight trainer.

### Milestone D - SaaS distribuibile

Include fasi 9, 12, 13. Risultato: template/cataloghi maturi, abbonamenti, TestFlight/App Store.
