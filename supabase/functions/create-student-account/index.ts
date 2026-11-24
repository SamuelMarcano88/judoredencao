import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, apikey, x-client-info, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const jsonResponse = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

const usernamePattern = /^[a-z0-9][a-z0-9._-]{2,29}$/;
const uuidPattern =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  const authorization = request.headers.get("Authorization");
  const token = authorization?.match(/^Bearer\s+(.+)$/i)?.[1];
  if (!token) return jsonResponse({ error: "Authentication required." }, 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SUPABASE_SECRET_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    console.error("Missing Supabase URL or server-side service key.");
    return jsonResponse({ error: "Server is not configured." }, 500);
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: authData, error: authError } = await admin.auth.getUser(token);
  if (authError || !authData.user) {
    return jsonResponse({ error: "Authentication required." }, 401);
  }

  const { data: callerProfile, error: profileError } = await admin
    .from("profiles")
    .select("role")
    .eq("id", authData.user.id)
    .maybeSingle();
  if (profileError) {
    console.error("Could not verify caller role:", profileError.message);
    return jsonResponse({ error: "Could not verify account permissions." }, 500);
  }

  if (callerProfile?.role !== "parent" && callerProfile?.role !== "admin") {
    return jsonResponse({ error: "Not authorized to create students." }, 403);
  }

  let payload: Record<string, unknown>;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "Invalid request body." }, 400);
  }

  const fullName = typeof payload.fullName === "string"
    ? payload.fullName.trim()
    : "";
  const username = typeof payload.username === "string"
    ? payload.username.trim().toLowerCase()
    : "";
  const password = typeof payload.password === "string"
    ? payload.password
    : "";
  const birthDate = typeof payload.birthDate === "string"
    ? payload.birthDate
    : null;
  const relationship = typeof payload.relationship === "string"
    ? payload.relationship.trim().slice(0, 40)
    : null;

  if (fullName.length < 2 || fullName.length > 100) {
    return jsonResponse({ error: "Student name must be 2 to 100 characters." }, 400);
  }
  if (!usernamePattern.test(username)) {
    return jsonResponse({ error: "Username must be 3 to 30 valid characters." }, 400);
  }
  if (password.length < 8 || password.length > 72) {
    return jsonResponse({ error: "Student password must be 8 to 72 characters." }, 400);
  }
  if (birthDate && !/^\d{4}-\d{2}-\d{2}$/.test(birthDate)) {
    return jsonResponse({ error: "Birth date must use YYYY-MM-DD format." }, 400);
  }

  let parentUserId: string;
  if (callerProfile.role === "parent") {
    parentUserId = authData.user.id;
  } else {
    const requestedParentId = payload.parentUserId;
    if (typeof requestedParentId !== "string" || !uuidPattern.test(requestedParentId)) {
      return jsonResponse({ error: "Select a valid parent account." }, 400);
    }
    const { data: parentProfile, error: parentError } = await admin
      .from("profiles")
      .select("id")
      .eq("id", requestedParentId)
      .eq("role", "parent")
      .maybeSingle();
    if (parentError) {
      console.error("Could not verify selected parent:", parentError.message);
      return jsonResponse({ error: "Could not verify the selected parent." }, 500);
    }
    if (!parentProfile) {
      return jsonResponse({ error: "Selected parent account was not found." }, 404);
    }
    parentUserId = parentProfile.id;
  }

  const { data: usernameTaken, error: usernameError } = await admin
    .from("student_access")
    .select("id")
    .eq("username", username)
    .maybeSingle();
  if (usernameError) {
    console.error("Could not check username availability:", usernameError.message);
    return jsonResponse({ error: "Could not verify username availability." }, 500);
  }
  if (usernameTaken) {
    return jsonResponse({ error: "That username is already in use." }, 409);
  }

  const { data: student, error: studentError } = await admin
    .from("students")
    .insert({
      full_name: fullName,
      birth_date: birthDate,
    })
    .select("id")
    .single();
  if (studentError || !student) {
    console.error("Could not create student:", studentError?.message);
    return jsonResponse({ error: "Could not create student profile." }, 500);
  }

  const syntheticEmail = `student-${username}@students.judoredencao.invalid`;
  let authUserId: string | null = null;
  try {
    const { data: newAuthUser, error: createUserError } = await admin.auth.admin
      .createUser({
        email: syntheticEmail,
        password,
        email_confirm: true,
        user_metadata: {
          full_name: fullName,
          preferred_language: "pt",
        },
      });
    if (createUserError || !newAuthUser.user) {
      throw new Error(createUserError?.message ?? "Could not create student login.");
    }
    authUserId = newAuthUser.user.id;

    const { error: roleUpdateError } = await admin
      .from("profiles")
      .update({ role: "student", full_name: fullName })
      .eq("id", authUserId);
    if (roleUpdateError) throw roleUpdateError;

    const { data: studentProfile, error: studentProfileError } = await admin
      .from("profiles")
      .select("id")
      .eq("id", authUserId)
      .maybeSingle();
    if (studentProfileError || !studentProfile) {
      throw new Error("Student profile trigger did not create a profile.");
    }

    const { error: linkError } = await admin.from("parent_student").insert({
      parent_user_id: parentUserId,
      student_id: student.id,
      relationship,
    });
    if (linkError) throw linkError;

    const { error: accessError } = await admin.from("student_access").insert({
      student_id: student.id,
      auth_user_id: authUserId,
      username,
    });
    if (accessError) throw accessError;

    return jsonResponse({
      student: {
        id: student.id,
        fullName,
        birthDate,
        username,
      },
    }, 201);
  } catch (error) {
    console.error("Student account creation failed:", error);
    if (authUserId) {
      const { error: deleteUserError } = await admin.auth.admin.deleteUser(authUserId);
      if (deleteUserError) {
        console.error("Could not remove incomplete student auth user:", deleteUserError.message);
      }
    }
    const { error: deleteStudentError } = await admin
      .from("students")
      .delete()
      .eq("id", student.id);
    if (deleteStudentError) {
      console.error("Could not remove incomplete student profile:", deleteStudentError.message);
    }
    if (error instanceof Error && error.message.toLowerCase().includes("already registered")) {
      return jsonResponse({ error: "That username is already in use." }, 409);
    }
    return jsonResponse({ error: "Could not create student account." }, 500);
  }
});
