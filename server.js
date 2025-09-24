// Updated Backend server for the Vouch Geofence application
// Using the official Supabase client library

const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const cors = require('cors');

// --- 1. INITIAL SETUP ---
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// --- 2. SUPABASE CLIENT SETUP ---
// Get Supabase credentials from environment variables on Render
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
  console.error("FATAL ERROR: Supabase URL or Service Key is not set in environment variables.");
  process.exit(1);
}

// Create a single, reusable Supabase client for the backend
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// --- 3. API ENDPOINT ---
app.post('/api/geofence', async (req, res) => {
    const { geometry } = req.body;

    if (!geometry) {
        return res.status(400).json({ error: 'Invalid GeoJSON. "geometry" object is missing.' });
    }

    console.log(`Received geofence data at ${new Date().toLocaleTimeString('en-IN')}`);

    try {
        // Call the 'create_geofence' function in your PostgreSQL database
        // RPC stands for Remote Procedure Call
        const { data, error } = await supabase
            .rpc('create_geofence', {
                business_name: 'Sample Business from Supabase Client',
                geofence_data: geometry
            });

        // Handle any errors from the database function
        if (error) {
            throw error;
        }

        console.log(`✅ Geofence saved successfully with ID: ${data}`);
        
        res.status(201).json({
            message: 'Geofence saved successfully!',
            id: data
        });

    } catch (err) {
        console.error("❌ Error saving geofence:", err);
        res.status(500).json({ error: err.message || 'An internal server error occurred.' });
    }
});

// --- 4. START THE SERVER ---
app.listen(PORT, () => {
    console.log(`🚀 Server is listening on port ${PORT}`);
});