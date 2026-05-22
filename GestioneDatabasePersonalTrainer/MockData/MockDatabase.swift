import Foundation

@MainActor
final class MockDatabase {
    static let shared = MockDatabase()

    var trainer: Trainer
    var clients: [Client]
    var appointments: [Appointment]
    var machines: [Machine]
    var workoutPlans: [WorkoutPlan]
    var nutritionPlans: [NutritionPlan]
    var progressEntries: [ProgressEntry]
    var accessCodes: [AccessCode]

    private init() {
        let trainerID = UUID(uuidString: "8D3E2657-0500-4D69-A37A-C3BD763C0B01")!
        let userID = UUID(uuidString: "09D4E067-C1D4-4B72-B9B6-7F48CE6B8B01")!
        let clientOneID = UUID(uuidString: "0A1B9425-8E4C-48DD-9DAD-01DA8BFB4D11")!
        let clientTwoID = UUID(uuidString: "E1D24C79-C089-4B91-A00F-1A5A74E8BD22")!
        let legPressID = UUID(uuidString: "5526C3D2-48FE-4F25-B0A4-B850E4BFF101")!
        let latMachineID = UUID(uuidString: "0990A818-F772-47D2-A082-A5119E44D201")!

        trainer = Trainer(
            id: trainerID,
            userID: userID,
            firstName: "Marco",
            lastName: "Rinaldi",
            email: "trainer@demo.it",
            studioName: "Rinaldi Performance Studio",
            subscriptionTier: .pro
        )

        clients = [
            Client(
                id: clientOneID,
                trainerID: trainerID,
                firstName: "Giulia",
                lastName: "Bianchi",
                email: "giulia.bianchi@example.com",
                phone: "+39 333 128 4501",
                birthDate: .daysFromNow(-10950),
                heightCm: 168,
                initialWeightKg: 68.4,
                currentWeightKg: 64.8,
                goal: "Ricomposizione corporea",
                accessCode: "PT-8F92KQ",
                joinedAt: .daysFromNow(-46),
                trainerNotes: "Ottima costanza. Preferisce sessioni mattutine."
            ),
            Client(
                id: clientTwoID,
                trainerID: trainerID,
                firstName: "Luca",
                lastName: "Ferrari",
                email: "luca.ferrari@example.com",
                phone: "+39 347 901 1187",
                birthDate: .daysFromNow(-12775),
                heightCm: 181,
                initialWeightKg: 82.0,
                currentWeightKg: 79.6,
                goal: "Ipertrofia e postura",
                accessCode: "PT-4N7YVB",
                joinedAt: .daysFromNow(-18),
                trainerNotes: "Attenzione alla mobilita scapolare."
            )
        ]

        appointments = [
            Appointment(
                id: UUID(),
                trainerID: trainerID,
                clientID: clientOneID,
                date: .daysFromNow(0, hour: 10),
                startTime: .daysFromNow(0, hour: 10),
                endTime: .daysFromNow(0, hour: 11),
                sessionType: .workout,
                notes: "Focus tecnica su squat e spinte.",
                status: .scheduled
            ),
            Appointment(
                id: UUID(),
                trainerID: trainerID,
                clientID: clientTwoID,
                date: .daysFromNow(1, hour: 17),
                startTime: .daysFromNow(1, hour: 17),
                endTime: .daysFromNow(1, hour: 18),
                sessionType: .checkin,
                notes: "Controllo carichi e aderenza alimentare.",
                status: .scheduled
            )
        ]

        machines = [
            Machine(id: legPressID, trainerID: trainerID, name: "Leg Press 45", muscleGroup: .legs, description: "Pressa inclinata per quadricipiti e glutei.", usageNotes: "Controllare profondita e ginocchia in linea.", imageName: nil, isAvailable: true),
            Machine(id: latMachineID, trainerID: trainerID, name: "Lat Machine", muscleGroup: .back, description: "Trazione verticale guidata.", usageNotes: "Evitare compensi lombari.", imageName: nil, isAvailable: true),
            Machine(id: UUID(), trainerID: trainerID, name: "Cavi regolabili", muscleGroup: .fullBody, description: "Stazione multifunzione per isolamento e richiamo.", usageNotes: "Verificare altezza carrucole.", imageName: nil, isAvailable: false)
        ]

        let workoutDayOne = WorkoutDay(
            id: UUID(),
            title: "Petto e Tricipiti",
            dayIndex: 1,
            exercises: [
                Exercise(id: UUID(), name: "Panca piana", machineID: nil, muscleGroup: .chest, sets: 4, reps: "8", restSeconds: 90, recommendedLoad: "RPE 8", technicalNotes: "Scapole addotte, traiettoria controllata.", order: 1),
                Exercise(id: UUID(), name: "Croci ai cavi", machineID: nil, muscleGroup: .chest, sets: 3, reps: "12", restSeconds: 60, recommendedLoad: "Moderato", technicalNotes: "Mantieni gomiti morbidi.", order: 2),
                Exercise(id: UUID(), name: "Pushdown corda", machineID: nil, muscleGroup: .triceps, sets: 3, reps: "12-15", restSeconds: 60, recommendedLoad: "Tecnico", technicalNotes: "Estensione completa senza slancio.", order: 3)
            ]
        )

        let workoutDayTwo = WorkoutDay(
            id: UUID(),
            title: "Dorso e Bicipiti",
            dayIndex: 2,
            exercises: [
                Exercise(id: UUID(), name: "Lat machine", machineID: latMachineID, muscleGroup: .back, sets: 4, reps: "10", restSeconds: 75, recommendedLoad: "Progressivo", technicalNotes: "Petto alto e gomiti verso il basso.", order: 1),
                Exercise(id: UUID(), name: "Rematore manubrio", machineID: nil, muscleGroup: .back, sets: 3, reps: "10 per lato", restSeconds: 75, recommendedLoad: "RPE 7", technicalNotes: "Non ruotare il busto.", order: 2),
                Exercise(id: UUID(), name: "Curl manubri", machineID: nil, muscleGroup: .biceps, sets: 3, reps: "12", restSeconds: 60, recommendedLoad: "Controllato", technicalNotes: "Eccentrica lenta.", order: 3)
            ]
        )

        workoutPlans = [
            WorkoutPlan(
                id: UUID(),
                trainerID: trainerID,
                clientID: clientOneID,
                name: "Ipertrofia 4 settimane",
                goal: "Aumento massa magra",
                createdAt: .daysFromNow(-12),
                startDate: .daysFromNow(-10),
                endDate: .daysFromNow(18),
                status: .active,
                days: [workoutDayOne, workoutDayTwo]
            )
        ]

        nutritionPlans = [
            NutritionPlan(
                id: UUID(),
                trainerID: trainerID,
                clientID: clientOneID,
                dailyCalories: 2050,
                proteinGrams: 140,
                carbohydrateGrams: 230,
                fatGrams: 58,
                targetWeightKg: 63.5,
                notes: "Bere almeno 2 litri d'acqua. Distribuire le proteine nei pasti principali.",
                startDate: .daysFromNow(-7),
                endDate: .daysFromNow(21),
                meals: [
                    Meal(id: UUID(), name: "Colazione", time: .daysFromNow(0, hour: 7, minute: 30), foods: [
                        MealFood(id: UUID(), name: "Yogurt greco", quantity: "170 g", notes: ""),
                        MealFood(id: UUID(), name: "Fiocchi d'avena", quantity: "50 g", notes: "Con frutti rossi")
                    ], notes: "Caffe senza zucchero opzionale."),
                    Meal(id: UUID(), name: "Pranzo", time: .daysFromNow(0, hour: 13), foods: [
                        MealFood(id: UUID(), name: "Riso basmati", quantity: "90 g", notes: "Peso a crudo"),
                        MealFood(id: UUID(), name: "Pollo", quantity: "160 g", notes: "Alla piastra"),
                        MealFood(id: UUID(), name: "Verdure", quantity: "libere", notes: "")
                    ], notes: "Olio EVO 10 g."),
                    Meal(id: UUID(), name: "Cena", time: .daysFromNow(0, hour: 20), foods: [
                        MealFood(id: UUID(), name: "Salmone", quantity: "150 g", notes: ""),
                        MealFood(id: UUID(), name: "Patate", quantity: "250 g", notes: ""),
                        MealFood(id: UUID(), name: "Insalata", quantity: "libera", notes: "")
                    ], notes: "")
                ]
            )
        ]

        progressEntries = [
            ProgressEntry(id: UUID(), clientID: clientOneID, date: .daysFromNow(-21), weightKg: 66.7, waistCm: 75, chestCm: 91, armCm: 29, legCm: 53, frontPhotoName: "progress_front_1", sidePhotoName: "progress_side_1", backPhotoName: nil, notes: "Primo controllo positivo."),
            ProgressEntry(id: UUID(), clientID: clientOneID, date: .daysFromNow(-4), weightKg: 64.8, waistCm: 72, chestCm: 90, armCm: 29.5, legCm: 53.5, frontPhotoName: "progress_front_2", sidePhotoName: "progress_side_2", backPhotoName: "progress_back_2", notes: "Migliore definizione addominale.")
        ]

        accessCodes = clients.map {
            AccessCode(id: UUID(), code: $0.accessCode, trainerID: trainerID, clientID: $0.id, createdAt: $0.joinedAt, isActive: true)
        }
    }
}
