import { createClient } from "@supabase/supabase-js";

// Consistently use Vite's import.meta.env
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    "Missing Supabase environment variables. Make sure VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are set in your .env file."
  );
}

// This client is ONLY for auth.
export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Auth helpers
export const authHelpers = {
  // --- SIGN UP ---
  async signUp(email, password, businessName) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          // This metadata is read by the SQL trigger
          role: "admin",
          business_name: businessName,
        },
      },
    });
    return { data, error };
  },

  // --- ADDED: OTP verification specifically for the signup flow ---
  async verifySignupOtp(email, token) {
    const { data, error } = await supabase.auth.verifyOtp({
      email,
      token,
      type: "signup", // This 'type' is crucial for signup verification
    });
    return { data, error };
  },

  async signInWithPassword(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    return { data, error };
  },

  // --- SIGN IN (Step 2: Send OTP) ---
  async sendSignInOtp(email) {
    const { data, error } = await supabase.auth.signInWithOtp({
      email: email,
      options: {
        shouldCreateUser: false,
      },
    });
    return { data, error };
  },

  // --- SIGN IN (Step 2: Verify OTP) ---
  async verifySignInOtp(email, token) {
    const { data, error } = await supabase.auth.verifyOtp({
      email,
      token,
      type: "email", // Note the type is 'email' for passwordless/MFA sign-in
    });
    return { data, error };
  },

  async signOut() {
    const { error } = await supabase.auth.signOut();
    return { error };
  },

  async getUser() {
    const {
      data: { user },
      error,
    } = await supabase.auth.getUser();
    return { user, error };
  },

  async getSession() {
    const {
      data: { session },
      error,
    } = await supabase.auth.getSession();
    return { session, error };
  },

  onAuthStateChange(callback) {
    return supabase.auth.onAuthStateChange(callback);
  },
};
