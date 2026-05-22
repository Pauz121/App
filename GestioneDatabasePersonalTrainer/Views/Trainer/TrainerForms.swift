import SwiftUI

struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var client: Client
    let onSave: (Client) -> Void

    init(client: Client, onSave: @escaping (Client) -> Void) {
        _client = State(initialValue: client)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Anagrafica") {
                    TextField("Nome", text: $client.firstName)
                    TextField("Cognome", text: $client.lastName)
                    TextField("Email", text: $client.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Telefono", text: $client.phone)
                        .keyboardType(.phonePad)
                    DatePicker("Data nascita", selection: $client.birthDate, displayedComponents: .date)
                }

                Section("Dati fisici") {
                    TextField("Altezza", value: $client.heightCm, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Peso iniziale", value: $client.initialWeightKg, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Peso attuale", value: $client.currentWeightKg, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Obiettivo", text: $client.goal, axis: .vertical)
                }

                Section("Accesso") {
                    HStack {
                        Text("Codice")
                        Spacer()
                        Text(client.accessCode)
                            .font(.system(.body, design: .monospaced).weight(.semibold))
                            .foregroundStyle(AppColors.success)
                    }
                }

                Section("Note trainer") {
                    TextEditor(text: $client.trainerNotes)
                        .frame(minHeight: 110)
                }
            }
            .navigationTitle(client.firstName.isEmpty ? "Nuovo cliente" : "Modifica cliente")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave(client)
                        dismiss()
                    }
                    .disabled(client.firstName.isEmpty || client.lastName.isEmpty)
                }
            }
        }
    }
}

struct AddAppointmentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appointment: Appointment
    let clients: [Client]
    let onSave: (Appointment) -> Void

    init(trainer: Trainer, clients: [Client], appointment: Appointment? = nil, onSave: @escaping (Appointment) -> Void) {
        self.clients = clients
        let firstClientID = clients.first?.id ?? UUID()
        _appointment = State(initialValue: appointment ?? Appointment(
            id: UUID(),
            trainerID: trainer.id,
            clientID: firstClientID,
            date: Date(),
            startTime: .daysFromNow(0, hour: 10),
            endTime: .daysFromNow(0, hour: 11),
            sessionType: .workout,
            notes: "",
            status: .scheduled
        ))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cliente") {
                    Picker("Cliente", selection: $appointment.clientID) {
                        ForEach(clients) { client in
                            Text(client.fullName).tag(client.id)
                        }
                    }
                }

                Section("Sessione") {
                    DatePicker("Inizio", selection: $appointment.startTime)
                    DatePicker("Fine", selection: $appointment.endTime)
                    Picker("Tipologia", selection: $appointment.sessionType) {
                        ForEach(SessionType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("Stato", selection: $appointment.status) {
                        ForEach(AppointmentStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }

                Section("Note") {
                    TextEditor(text: $appointment.notes)
                        .frame(minHeight: 90)
                }
            }
            .navigationTitle("Appuntamento")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        appointment.date = appointment.startTime
                        onSave(appointment)
                        dismiss()
                    }
                    .disabled(clients.isEmpty)
                }
            }
        }
    }
}

struct AddMachineView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var machine: Machine
    @State private var catalog: [MachineCatalogDTO] = []
    @State private var selectedCatalogID: UUID?
    let catalogService: CatalogService?
    let onSave: (Machine) -> Void

    init(machine: Machine, catalogService: CatalogService? = nil, onSave: @escaping (Machine) -> Void) {
        _machine = State(initialValue: machine)
        self.catalogService = catalogService
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                if !catalog.isEmpty {
                    Section("Catalogo globale") {
                        Picker("Scegli dal catalogo", selection: $selectedCatalogID) {
                            Text("Personalizzato").tag(Optional<UUID>.none)
                            ForEach(catalog) { item in
                                Text("\(item.name) - \(item.muscleGroup)").tag(Optional(item.id))
                            }
                        }
                        .onChange(of: selectedCatalogID) { _, newValue in
                            guard let newValue, let item = catalog.first(where: { $0.id == newValue }) else { return }
                            machine.name = item.name
                            machine.muscleGroup = MuscleGroup.allCases.first(where: { $0.rawValue == item.muscleGroup }) ?? .fullBody
                            machine.description = item.description ?? ""
                            machine.usageNotes = item.usageNotes ?? ""
                        }
                    }
                }

                Section("Macchinario") {
                    TextField("Nome", text: $machine.name)
                    Picker("Gruppo muscolare", selection: $machine.muscleGroup) {
                        ForEach(MuscleGroup.allCases) { group in
                            Text(group.rawValue).tag(group)
                        }
                    }
                    Toggle("Disponibile", isOn: $machine.isAvailable)
                }

                Section("Descrizione") {
                    TextField("Descrizione", text: $machine.description, axis: .vertical)
                    TextField("Note utilizzo", text: $machine.usageNotes, axis: .vertical)
                }
            }
            .navigationTitle(machine.name.isEmpty ? "Nuovo macchinario" : "Modifica")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        onSave(machine)
                        dismiss()
                    }
                    .disabled(machine.name.isEmpty)
                }
            }
            .task {
                catalog = await catalogService?.fetchMachineCatalog() ?? []
            }
        }
    }
}

struct CreateWorkoutPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedClientID: UUID
    @State private var selectedTemplateID: UUID?
    @State private var templates: [WorkoutTemplateDTO] = []
    @State private var exercises: [ExerciseCatalogDTO] = []
    @State private var name = "Ipertrofia 4 settimane"
    @State private var goal = "Aumento massa magra"
    let clients: [Client]
    let catalogService: CatalogService?
    let onCreate: (Client, String, String) -> Void

    init(clients: [Client], catalogService: CatalogService? = nil, onCreate: @escaping (Client, String, String) -> Void) {
        self.clients = clients
        self.catalogService = catalogService
        _selectedClientID = State(initialValue: clients.first?.id ?? UUID())
        self.onCreate = onCreate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cliente") {
                    Picker("Cliente", selection: $selectedClientID) {
                        ForEach(clients) { client in
                            Text(client.fullName).tag(client.id)
                        }
                    }
                }

                Section("Scheda") {
                    if !templates.isEmpty {
                        Picker("Template", selection: $selectedTemplateID) {
                            Text("Nessun template").tag(Optional<UUID>.none)
                            ForEach(templates) { template in
                                Text(template.name).tag(Optional(template.id))
                            }
                        }
                        .onChange(of: selectedTemplateID) { _, newValue in
                            guard let newValue, let template = templates.first(where: { $0.id == newValue }) else { return }
                            name = template.name
                            goal = template.goal ?? goal
                        }
                    }
                    TextField("Nome scheda", text: $name)
                    TextField("Obiettivo", text: $goal, axis: .vertical)
                }

                Section("Catalogo esercizi") {
                    Text(exercises.isEmpty ? "Configura Supabase o accedi per leggere gli esercizi globali." : "\(exercises.count) esercizi disponibili nel catalogo globale. Quando assegni una scheda, gli esercizi vengono copiati nelle tabelle operative del cliente.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Crea scheda")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crea") {
                        if let client = clients.first(where: { $0.id == selectedClientID }) {
                            onCreate(client, name, goal)
                        }
                        dismiss()
                    }
                    .disabled(clients.isEmpty || name.isEmpty)
                }
            }
            .task {
                templates = await catalogService?.fetchWorkoutTemplates() ?? []
                exercises = await catalogService?.fetchExerciseCatalog() ?? []
            }
        }
    }
}

struct CreateNutritionPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedClientID: UUID
    @State private var selectedMealTemplateID: UUID?
    @State private var mealTemplates: [MealTemplateDTO] = []
    @State private var foods: [FoodCatalogDTO] = []
    @State private var calories = 2100
    @State private var targetWeight = 70.0
    let clients: [Client]
    let catalogService: CatalogService?
    let onCreate: (Client, Int, Double) -> Void

    init(clients: [Client], catalogService: CatalogService? = nil, onCreate: @escaping (Client, Int, Double) -> Void) {
        self.clients = clients
        self.catalogService = catalogService
        _selectedClientID = State(initialValue: clients.first?.id ?? UUID())
        self.onCreate = onCreate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Cliente") {
                    Picker("Cliente", selection: $selectedClientID) {
                        ForEach(clients) { client in
                            Text(client.fullName).tag(client.id)
                        }
                    }
                }

                Section("Target") {
                    Stepper("Calorie: \(calories) kcal", value: $calories, in: 1200...4500, step: 50)
                    TextField("Peso obiettivo", value: $targetWeight, format: .number)
                        .keyboardType(.decimalPad)
                }

                Section("Template pasti") {
                    if mealTemplates.isEmpty {
                        Text("Configura Supabase o accedi per leggere i template pasto.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Pasto base", selection: $selectedMealTemplateID) {
                            Text("Nessuno").tag(Optional<UUID>.none)
                            ForEach(mealTemplates) { template in
                                Text(template.name).tag(Optional(template.id))
                            }
                        }
                    }
                    Text("\(foods.count) alimenti disponibili nel food catalog.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Crea piano")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crea") {
                        if let client = clients.first(where: { $0.id == selectedClientID }) {
                            onCreate(client, calories, targetWeight)
                        }
                        dismiss()
                    }
                    .disabled(clients.isEmpty)
                }
            }
            .task {
                mealTemplates = await catalogService?.fetchMealTemplates() ?? []
                foods = await catalogService?.fetchFoodCatalog() ?? []
            }
        }
    }
}
