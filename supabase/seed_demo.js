// Creates demo Supabase Auth users and linked SaaS demo data.
// Usage:
//   SUPABASE_URL=https://YOUR_PROJECT.supabase.co SUPABASE_SERVICE_ROLE_KEY=... node supabase/seed_demo.js
//
// Never ship the service role key inside the iOS app.

import { createClient } from "@supabase/supabase-js";

const url = process.env.SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !serviceRoleKey) {
  console.error("Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY");
  process.exit(1);
}

const supabase = createClient(url, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

async function ensureUser(email, password, metadata) {
  const { data: existing } = await supabase.auth.admin.listUsers();
  const found = existing.users.find((user) => user.email === email);
  if (found) return found;

  const { data, error } = await supabase.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: metadata,
  });

  if (error) throw error;
  return data.user;
}

async function main() {
  const trainerUser = await ensureUser("demo.trainer@test.com", "DemoTrainer123!", {
    first_name: "Marco",
    last_name: "Rossi",
    role: "trainer",
  });

  const clientUser = await ensureUser("demo.cliente@test.com", "DemoCliente123!", {
    first_name: "Luca",
    last_name: "Bianchi",
    role: "client",
  });

  const { data: proPlan, error: planError } = await supabase
    .from("subscription_plans")
    .select("*")
    .eq("slug", "pro")
    .single();
  if (planError) throw planError;

  await supabase.from("profiles").upsert([
    {
      id: trainerUser.id,
      role: "trainer",
      email: "demo.trainer@test.com",
      first_name: "Marco",
      last_name: "Rossi",
      phone: "+39 333 100 2000",
    },
    {
      id: clientUser.id,
      role: "client",
      email: "demo.cliente@test.com",
      first_name: "Luca",
      last_name: "Bianchi",
      phone: "+39 333 900 1100",
    },
  ]);

  const { data: trainer, error: trainerError } = await supabase
    .from("trainers")
    .upsert({
      user_id: trainerUser.id,
      business_name: "MR Personal Coaching",
      phone: "+39 333 100 2000",
      max_clients: proPlan.max_clients,
      status: "active",
    }, { onConflict: "user_id" })
    .select()
    .single();
  if (trainerError) throw trainerError;

  await supabase.from("trainer_subscriptions").insert({
    trainer_id: trainer.id,
    plan_id: proPlan.id,
    status: "active",
    starts_at: new Date().toISOString(),
    current_period_start: new Date().toISOString(),
    current_period_end: new Date(Date.now() + 30 * 86400000).toISOString(),
    provider: "manual_demo",
  });

  const { data: clients, error: clientsError } = await supabase
    .from("clients")
    .upsert([
      {
        trainer_id: trainer.id,
        user_id: clientUser.id,
        status: "active",
        first_name: "Luca",
        last_name: "Bianchi",
        email: "demo.cliente@test.com",
        phone: "+39 333 900 1100",
        birth_date: "1992-04-12",
        height_cm: 178,
        initial_weight_kg: 82,
        current_weight_kg: 78,
        goal: "Ricomposizione corporea / aumento massa magra",
        notes: "Cliente demo gia registrato.",
        joined_at: new Date(Date.now() - 25 * 86400000).toISOString(),
      },
      {
        trainer_id: trainer.id,
        status: "pending_registration",
        first_name: "Giulia",
        last_name: "Verdi",
        email: "giulia.verdi@example.com",
        phone: "+39 347 440 1188",
        birth_date: "1995-09-08",
        height_cm: 166,
        initial_weight_kg: 67,
        current_weight_kg: 65,
        goal: "Tonificazione e postura",
        notes: "Preferisce allenarsi al mattino.",
      },
      {
        trainer_id: trainer.id,
        status: "pending_registration",
        first_name: "Andrea",
        last_name: "Neri",
        email: "andrea.neri@example.com",
        phone: "+39 348 150 7788",
        birth_date: "1988-01-21",
        height_cm: 184,
        initial_weight_kg: 88,
        current_weight_kg: 86,
        goal: "Forza e riduzione massa grassa",
        notes: "Attenzione a fastidio lombare.",
      },
    ])
    .select();
  if (clientsError) throw clientsError;

  const luca = clients.find((client) => client.email === "demo.cliente@test.com");
  const pendingClients = clients.filter((client) => client.status === "pending_registration");

  for (const client of pendingClients) {
    const { data: code, error } = await supabase.rpc("generate_client_invite_code", {
      p_trainer_id: trainer.id,
      p_client_id: client.id,
    });
    if (error) throw error;
    console.log(`Invite for ${client.first_name} ${client.last_name}: ${code}`);
  }

  await supabase.from("client_invite_codes").insert({
    trainer_id: trainer.id,
    client_id: luca.id,
    code: "PT-DEMOOLD",
    status: "used",
    expires_at: new Date(Date.now() + 14 * 86400000).toISOString(),
    used_at: new Date(Date.now() - 20 * 86400000).toISOString(),
    used_by_user_id: clientUser.id,
  });

  const machineRows = [
    ["Leg Press 45", "Gambe"], ["Lat Machine", "Dorso"], ["Chest Press", "Petto"],
    ["Shoulder Press", "Spalle"], ["Cavi regolabili", "Full body"], ["Hack Squat", "Gambe"],
    ["Tapis Roulant", "Cardio"], ["Bike", "Cardio"], ["Abductor Machine", "Glutei"], ["Panca Scott", "Bicipiti"],
  ].map(([name, group]) => ({
    trainer_id: trainer.id,
    name,
    muscle_group: group,
    description: `${name} per lavoro su ${group.toLowerCase()}.`,
    usage_notes: "Controllare setup e tecnica prima di aumentare il carico.",
    is_available: true,
  }));
  await supabase.from("machines").insert(machineRows);

  await supabase.from("appointments").insert([
    { trainer_id: trainer.id, client_id: luca.id, title: "Upper body", session_type: "Allenamento", starts_at: new Date(Date.now() + 1 * 86400000).toISOString(), ends_at: new Date(Date.now() + 1 * 86400000 + 3600000).toISOString(), status: "scheduled", notes: "Focus spinte e tirate." },
    { trainer_id: trainer.id, client_id: luca.id, title: "Check-in", session_type: "Check-in", starts_at: new Date(Date.now() + 3 * 86400000).toISOString(), ends_at: new Date(Date.now() + 3 * 86400000 + 1800000).toISOString(), status: "scheduled", notes: "Misure e feedback dieta." },
    ...pendingClients.map((client, index) => ({ trainer_id: trainer.id, client_id: client.id, title: "Valutazione iniziale", session_type: "Valutazione", starts_at: new Date(Date.now() + (index + 4) * 86400000).toISOString(), ends_at: new Date(Date.now() + (index + 4) * 86400000 + 3600000).toISOString(), status: "scheduled", notes: "Prima analisi movimento." })),
    { trainer_id: trainer.id, client_id: luca.id, title: "Lower body", session_type: "Allenamento", starts_at: new Date(Date.now() + 7 * 86400000).toISOString(), ends_at: new Date(Date.now() + 7 * 86400000 + 3600000).toISOString(), status: "scheduled", notes: "Progressione gambe." },
  ]);

  const { data: plan } = await supabase.from("workout_plans").insert({
    trainer_id: trainer.id,
    client_id: luca.id,
    name: "Ipertrofia 4 settimane",
    goal: "Aumento massa magra",
    starts_at: new Date().toISOString().slice(0, 10),
    ends_at: new Date(Date.now() + 28 * 86400000).toISOString().slice(0, 10),
    status: "active",
  }).select().single();

  for (const [dayIndex, dayName] of ["Petto e tricipiti", "Dorso e bicipiti", "Gambe e core"].entries()) {
    const { data: day } = await supabase.from("workout_days").insert({
      workout_plan_id: plan.id,
      name: dayName,
      day_order: dayIndex + 1,
    }).select().single();

    await supabase.from("exercises").insert(["Panca piana", "Lat machine", "Leg press", "Plank"].map((name, index) => ({
      workout_day_id: day.id,
      name,
      muscle_group: ["Petto", "Dorso", "Gambe", "Addome"][index],
      sets: index === 3 ? 3 : 4,
      reps: index === 3 ? "45 sec" : "8-12",
      rest_seconds: index === 3 ? 60 : 90,
      suggested_load: "RPE 7-8",
      technical_notes: "Esecuzione controllata e respirazione stabile.",
      exercise_order: index + 1,
    })));
  }

  const { data: nutrition } = await supabase.from("nutrition_plans").insert({
    trainer_id: trainer.id,
    client_id: luca.id,
    name: "Ricomposizione 2100 kcal",
    daily_calories: 2100,
    proteins_g: 150,
    carbs_g: 230,
    fats_g: 60,
    target_weight_kg: 77,
    notes: "Distribuire proteine nei pasti principali.",
    starts_at: new Date().toISOString().slice(0, 10),
    ends_at: new Date(Date.now() + 30 * 86400000).toISOString().slice(0, 10),
    status: "active",
  }).select().single();

  for (const [order, name] of ["Colazione", "Spuntino", "Pranzo", "Spuntino pomeridiano", "Cena"].entries()) {
    const { data: meal } = await supabase.from("meals").insert({
      nutrition_plan_id: nutrition.id,
      name,
      meal_time: ["07:30", "10:30", "13:00", "17:00", "20:30"][order],
      meal_order: order + 1,
    }).select().single();

    await supabase.from("meal_foods").insert([
      { meal_id: meal.id, food_name: "Fonte proteica", quantity: "150 g", proteins_g: 30 },
      { meal_id: meal.id, food_name: "Carboidrati complessi", quantity: "80 g", carbs_g: 55 },
    ]);
  }

  const progressRows = [82, 80.5, 79.2, 78].map((weight, index) => ({
    trainer_id: trainer.id,
    client_id: luca.id,
    entry_date: new Date(Date.now() - (30 - index * 10) * 86400000).toISOString().slice(0, 10),
    weight_kg: weight,
    waist_cm: 88 - index * 2,
    chest_cm: 101,
    arm_cm: 34 + index * 0.2,
    leg_cm: 58,
    notes: index === 3 ? "Miglioramento visibile nella postura." : "Progressione regolare.",
    created_by_user_id: clientUser.id,
  }));
  const { data: progressEntries } = await supabase.from("progress_entries").insert(progressRows).select();
  await supabase.from("progress_photos").insert(progressEntries.slice(0, 2).map((entry, index) => ({
    progress_entry_id: entry.id,
    trainer_id: trainer.id,
    client_id: luca.id,
    photo_type: index === 0 ? "front" : "side",
    storage_path: `${trainer.id}/${luca.id}/${entry.id}/${index === 0 ? "front" : "side"}_placeholder.jpg`,
  })));

  console.log("Demo seed completed.");
  console.log("Trainer: demo.trainer@test.com / DemoTrainer123!");
  console.log("Client: demo.cliente@test.com / DemoCliente123!");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
