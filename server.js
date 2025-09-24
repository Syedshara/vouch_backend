// Backend server for the Vouch Geofence application
// To be deployed on Render

const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

// --- 1. INITIAL SETUP ---
const app = express();
const PORT = process.env.PORT || 3000; // Render will provide the PORT variable

// Middleware
app.use(cors());      // Allows your front-end to communicate with this backend
app.use(express.json()); // Allows the server to understand JSON request bodies

// --- 2. DATABASE CONNECTION ---
// The connection string is read securely from an environment variable
// You will set this variable in the Render dashboard.
const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.error("❌ FATAL ERROR: DATABASE_URL environment variable is not set.");
  process.exit(1); // Exit the application if the database URL is missing
}

const pool = new Pool({
    connectionString: connectionString,
});

// --- 3. API ENDPOINT ---
// This endpoint receives the GeoJSON data from the front-end demo.
app.post('/api/geofence', async (req, res) => {
    // Extract the geometry object from the GeoJSON feature
    const { geometry } = req.body;

    // Validate that we received valid geometry data
    if (!geometry || !geometry.type || !geometry.coordinates) {
        return res.status(400).json({ error: 'Invalid GeoJSON data. The "geometry" object is missing or malformed.' });
    }

    console.log(`Received geofence data at ${new Date().toLocaleTimeString('en-IN')}`);

    try {
        // SQL query to insert the data using a PostGIS function
        // $1 and $2 are placeholders for secure parameter injection to prevent SQL injection
        const query = `
            INSERT INTO businesses (name, geofence) 
            VALUES ($1, ST_GeomFromGeoJSON($2))
            RETURNING id;
        `;
        
        // Use a sample name for the demo and stringify the geometry object for the query
        const values = ['Sample Business from Chennai', JSON.stringify(geometry)];

        // Execute the query
        const result = await pool.query(query, values);
        const newId = result.rows[0].id;

        console.log(`✅ Geofence saved successfully with ID: ${newId}`);
        
        // Send a success response back to the front-end
        res.status(201).json({ 
            message: 'Geofence saved successfully!', 
            id: newId 
        });

    } catch (err) {
        console.error("❌ Error saving geofence to the database:", err.stack);
        res.status(500).json({ error: 'An internal server error occurred.' });
    }
});

// --- 4. START THE SERVER ---
app.listen(PORT, () => {
    console.log(`🚀 Server is listening on port ${PORT}`);
});