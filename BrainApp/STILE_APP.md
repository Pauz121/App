# Stile attuale app

Data aggiornamento: 2026-05-17

## Identita visiva corrente

L'app usa uno stile dark, moderno, tecnico e abbastanza SaaS/dashboard. La palette e dominata da blu scuro, superfici antracite e accento blu acceso. L'effetto complessivo e professionale ma un po' generico da gestionale fitness tech.

## Palette

- Background: quasi nero/blu notte.
- Surface card: blu-grigio scuro.
- Elevated surface: variante piu chiara per bottoni secondari e placeholder.
- Accent: blu brillante.
- Success: verde.
- Violet: viola.
- Warning: giallo/arancio.
- Testi: bianco pieno e bianco al 66%.

## Tipografia

- Font di sistema Apple.
- Titoli principali rounded/bold.
- Hero: 36 pt bold rounded.
- Title: 24 pt bold rounded.
- Section: 18 pt semibold rounded.
- Body: 15 pt regular.
- Caption: 12 pt medium.

## Layout

- Struttura a card.
- Spaziatura costante: 6, 10, 16, 24, 32.
- Dashboard con griglie 2 colonne.
- Liste e sezioni verticali con `ScrollView`, `VStack`, `LazyVGrid`.
- Tab bar standard SwiftUI.
- NavigationStack standard.

## Componenti

- `StatCard`: card statistiche con icona colorata e numero grande.
- `SectionCard`: contenitore principale per blocchi informativi.
- `PrimaryButton`: bottone pieno blu.
- `SecondaryButton`: bottone scuro elevato.
- `EmptyStateView`: icona grande, titolo e messaggio.
- `SearchBarView`: barra scura con icona.
- `ClientRowView`, `AppointmentRowView`, `MachineCard`.
- `ProgressPhotoCard`: placeholder foto, non immagine reale.

## Forma e profondita

- Radius piccolo/medio: 8, 12, 18.
- Card con shadow scura importante.
- Bottoni con radius 8.
- Icone dentro riquadri colorati trasparenti.

## Punti forti

- Coerenza buona tra schermate.
- Design system centralizzato.
- Aspetto ordinato e leggibile.
- Palette adatta a dashboard e SaaS.
- Componenti riutilizzabili gia presenti.

## Punti deboli

- Estetica un po' generica.
- Dark mode forzata, nessuna light mode.
- Molte card e shadow possono appesantire l'interfaccia.
- Poco carattere specifico per personal trainer/fitness premium.
- Palette molto fredda, poco umana.
- Non c'e distinzione visiva forte tra area trainer e area cliente.
- Placeholder foto troppo basici.
- Alcune schermate sembrano piu mock/prototipo che prodotto finito.

## File principali dello stile

- `GestioneDatabasePersonalTrainer/DesignSystem/DesignSystem.swift`
- `GestioneDatabasePersonalTrainer/Views/Components/Components.swift`
- `GestioneDatabasePersonalTrainer/Views/Auth/AuthViews.swift`
- `GestioneDatabasePersonalTrainer/Views/Trainer/TrainerViews.swift`
- `GestioneDatabasePersonalTrainer/Views/Client/ClientViews.swift`

## Decisioni aperte

- Mantenere dark mode o introdurre light mode.
- Rendere lo stile piu premium/minimal oppure piu sportivo/energetico.
- Differenziare area trainer e area cliente.
- Ridurre card/shadow per un look piu nativo iOS.
- Introdurre immagini reali, avatar, foto progressi e asset branded.
