// Updated Backend server for the Vouch Geofence application
// Using the official Supabase client library

const express = require("express");
const { createClient } = require("@supabase/supabase-js");
const cors = require("cors");

// --- 1. INITIAL SETUP ---
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// --- 2. SUPABASE CLIENT SETUP ---
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error(
    "FATAL ERROR: Supabase URL or Service Key is not set in environment variables."
  );
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseServiceKey);

// --- 3. API ENDPOINT ---
app.post("/api/geofence", async (req, res) => {
  // UPDATED: Destructure both business_name and geometry from the request body
  const { business_name, geometry } = req.body;
  if (!supabaseUrl || !supabaseServiceKey) {
    console.error(
      "FATAL ERROR: Supabase URL or Service Key is not set in environment variables."
    );
  }

  // UPDATED: Validate both inputs
  if (!business_name || !geometry) {
    return res.status(400).json({
      error:
        'Request body must contain both "business_name" and "geometry" object.',
    });
  }
  if (!geometry.type || !geometry.coordinates) {
    return res.status(400).json({ error: 'Invalid "geometry" object.' });
  }

  console.log(
    `Received geofence for "${business_name}" at ${new Date().toLocaleTimeString(
      "en-IN"
    )}`
  );

  try {
    // Call the 'create_geofence' function in your PostgreSQL database
    const { data, error } = await supabase.rpc("create_geofence", {
      // UPDATED: Use the dynamic business_name from the request
      business_name: business_name,
      geofence_data: geometry,
    });

    if (error) {
      throw error;
    }

    console.log(`✅ Geofence saved successfully with ID: ${data}`);

    res.status(201).json({
      message: `Geofence for '${business_name}' saved successfully!`,
      id: data,
    });
  } catch (err) {
    console.error("❌ Error saving geofence:", err);
    res
      .status(500)
      .json({ error: err.message || "An internal server error occurred." });
  }
});

// --- 4. START THE SERVER ---
app.listen(PORT, () => {
  console.log(`🚀 Server is listening on port ${PORT}`);
});
