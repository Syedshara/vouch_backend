import express from "express";
import cors from "cors";
import { createClient } from "@supabase/supabase-js";
import "dotenv/config";
import crypto, { createSign } from "crypto"; // <-- 1. IMPORT createSign

const app = express();
const port = process.env.PORT || 8080;

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
// --- 2. LOAD THE NEW PRIVATE KEY ---
const serverPrivateKey = process.env.SERVER_PRIVATE_KEY?.replace(/\\n/g, "\n");

if (!supabaseUrl || !supabaseServiceKey) {
  throw new Error(
    "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY environment variables"
  );
}
// --- AND VALIDATE IT ---
if (!serverPrivateKey) {
  throw new Error(
    "Missing SERVER_PRIVATE_KEY. Run 'node generate-keys.js' and add it to .env"
  );
}

const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);
app.use(cors());
app.use(express.json({ limit: "10mb" }));

/**
 * VOUCHER GENERATION LOGIC
 */
// index.js

// ... (other code is unchanged) ...

/**
 * VOUCHER GENERATION LOGIC
 */
const triggerCampaigns = async (customer_id, location_id, business_id) => {
  console.log(
    `[Voucher] Checking campaigns for customer ${customer_id} at location ${location_id}`
  );

  try {
    const { data: campaign, error: campaignError } = await supabaseAdmin
      .from("campaigns")
      .select("id, reward_description, owner_id")
      .eq("owner_id", business_id)
      .eq("is_active", true)
      .or(`location_id.eq.${location_id},location_id.is.null`)
      .lte("start_date", new Date().toISOString())
      .gte("end_date", new Date().toISOString())
      .limit(1)
      .single();

    if (campaignError || !campaign) {
      console.log("[Voucher] No active campaigns found for this POP.");
      return;
    }

    console.log(`[Voucher] Found campaign ${campaign.id}, generating reward.`);

    // --- THIS IS THE FIX ---
    // Create a unique payload to sign
    const payload = JSON.stringify({
      customer: customer_id,
      campaign: campaign.id,
      timestamp: Date.now(),
      nonce: crypto.randomBytes(4).toString("hex"),
    });

    // Create a signer object
    const sign = createSign("SHA256");
    sign.update(payload);
    sign.end();

    // Sign the payload. We just pass the key variable directly.
    // The 'type' and 'format' are inferred from the PEM string.
    const unique_token = sign.sign(serverPrivateKey, "hex");
    // --- END OF FIX ---

    const { error: insertError } = await supabaseAdmin
      .from("customer_rewards")
      .insert({
        customer_id: customer_id,
        campaign_id: campaign.id,
        business_id: campaign.owner_id,
        location_id: location_id,
        reward_description: campaign.reward_description,
        unique_token: unique_token, // This is now an ECC signature
        status: "active",
      });

    if (insertError) {
      console.error("[Voucher] Error inserting new voucher:", insertError);
    } else {
      console.log(
        `[Voucher] Successfully created voucher (signature) for customer ${customer_id}`
      );
    }
  } catch (e) {
    console.error("[Voucher] General error in triggerCampaigns:", e.message);
  }
};

// ... (rest of your index.js file) ...

/**
 * AUTHENTICATION MIDDLEWARE
 */
const authMiddleware = async (req, res, next) => {
  // ... (this function is unchanged)
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res
      .status(401)
      .json({ error: "User not authenticated: Missing token" });
  }

  const token = authHeader.replace("Bearer ", "");
  const {
    data: { user },
    error,
  } = await supabaseAdmin.auth.getUser(token);

  if (error || !user) {
    return res
      .status(401)
      .json({ error: "User not authenticated: Invalid token" });
  }

  req.user = user;
  next();
};

app.get("/", (req, res) => {
  res.send("Vouch System Node.js Backend is running!");
});

/**
 * WEBHOOKS
 */
app.post("/api/loyalty-engine", (req, res) => {
  // ... (this function is unchanged)
  console.log("Loyalty engine triggered");
  res.status(200).json({ message: "Loyalty engine triggered" });
});

/**
 * ADMIN API
 */

app.get("/api/my-profile", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { data, error } = await supabaseAdmin
    .from("business_profiles")
    .select("*")
    .eq("id", req.user.id)
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.put("/api/my-profile", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { business_name, phone, website, description, email } = req.body;
  const { data, error } = await supabaseAdmin
    .from("business_profiles")
    .update({
      business_name,
      phone,
      website,
      description,
      email,
      updated_at: new Date(),
    })
    .eq("id", req.user.id)
    .select()
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.get("/api/locations", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { data, error } = await supabaseAdmin
    .from("locations")
    .select("*")
    .eq("owner_id", req.user.id)
    .order("created_at", { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.post("/api/locations", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { name, address, category, geofence, dwell_time_minutes } = req.body;
  const { data, error } = await supabaseAdmin
    .from("locations")
    .insert({
      owner_id: req.user.id,
      name,
      address,
      category,
      geofence: geofence.geometry,
      dwell_time_minutes,
      is_active: true,
    })
    .select()
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

app.put("/api/locations/:id", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { id } = req.params;
  const { name, address, category, dwell_time_minutes, is_active } = req.body;
  const { data, error } = await supabaseAdmin
    .from("locations")
    .update({ name, address, category, dwell_time_minutes, is_active })
    .eq("id", id)
    .eq("owner_id", req.user.id)
    .select()
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.delete("/api/locations/:id", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { id } = req.params;
  const { error } = await supabaseAdmin
    .from("locations")
    .delete()
    .eq("id", id)
    .eq("owner_id", req.user.id);

  if (error) return res.status(500).json({ error: error.message });
  res.status(204).send();
});

app.get("/api/rewards", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { data: rewards, error } = await supabaseAdmin
    .from("rewards")
    .select("*")
    .eq("owner_id", req.user.id);
  if (rewards && rewards.length === 0) {
    const { data: newReward } = await supabaseAdmin
      .from("rewards")
      .insert({
        owner_id: req.user.id,
        name: "Default Reward",
        description: "A test reward",
      })
      .select()
      .single();
    return res.status(200).json([newReward]);
  }
  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(rewards);
});

app.get("/api/campaigns", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { data, error } = await supabaseAdmin
    .from("campaigns")
    .select("*, locations:location_id(id, name)")
    .eq("owner_id", req.user.id)
    .order("created_at", { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.delete("/api/campaigns/:id", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { id } = req.params;
  const { error } = await supabaseAdmin
    .from("campaigns")
    .delete()
    .eq("id", id)
    .eq("owner_id", req.user.id);
  if (error) return res.status(500).json({ error: error.message });
  res.status(204).send();
});

app.get("/api/reviews", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { data, error } = await supabaseAdmin
    .from("reviews")
    .select("*, customers(name), locations(name)")
    .eq("business_id", req.user.id);

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.post("/api/rewards/redeem", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { unique_token } = req.body;
  const business_id = req.user.id;

  if (!unique_token) {
    return res.status(400).json({ error: "Missing voucher token." });
  }

  try {
    const { data: reward, error: findError } = await supabaseAdmin
      .from("customer_rewards")
      .select("*")
      .eq("unique_token", unique_token)
      .limit(1)
      .single();

    if (findError || !reward) {
      return res.status(404).json({ error: "Voucher not found." });
    }

    if (reward.business_id !== business_id) {
      return res
        .status(403)
        .json({ error: "Voucher not valid for this business." });
    }

    if (reward.status === "redeemed") {
      return res.status(409).json({
        error: "Voucher already redeemed",
        reward: {
          description: reward.reward_description,
          redeemed_at: reward.redeemed_at,
        },
      });
    }

    if (reward.status !== "active") {
      return res
        .status(400)
        .json({ error: `Voucher is not active (Status: ${reward.status})` });
    }

    const { data: updatedReward, error: updateError } = await supabaseAdmin
      .from("customer_rewards")
      .update({
        status: "redeemed",
        redeemed_at: new Date().toISOString(),
      })
      .eq("id", reward.id)
      .select("reward_description, redeemed_at")
      .single();

    if (updateError) {
      return res.status(500).json({ error: updateError.message });
    }

    res.status(200).json({
      message: "Voucher Redeemed Successfully!",
      reward: updatedReward,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * PUBLIC API
 */

app.get("/api/public/locations", async (req, res) => {
  // ... (this function is unchanged)
  const { sortBy } = req.query;
  const { data, error } = await supabaseAdmin.rpc("get_public_locations", {
    sort_by: sortBy || "new",
  });
  if (error) {
    console.error("Public locations error:", error.message);
    return res.status(500).json({ error: error.message });
  }
  const remappedData = data.map((loc) => ({
    id: loc.id,
    name: loc.name,
    address: loc.address,
    category: loc.category,
    latitude: loc.latitude,
    longitude: loc.longitude,
    vouchCount: loc.vouch_count || 0,
    geofence: loc.geofence_json,
    dwell_time_minutes: loc.dwell_time_minutes,
    campaign: "Visit 3 times, get a free coffee!",
    rating: 4.5,
    imageUrl: `https://images.unsplash.com/photo-1567521464027-f127ff144326?w=400&h=300&fit=crop`,
  }));
  res.status(200).json(remappedData);
});

app.get("/api/public/reviews/:location_id", async (req, res) => {
  // ... (this function is unchanged)
  const { location_id } = req.params;
  const { data, error } = await supabaseAdmin
    .from("reviews")
    .select(
      `
      id,
      rating,
      comment,
      created_at,
      customers ( name )
    `
    )
    .eq("location_id", location_id)
    .order("created_at", { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.get("/api/my-rewards", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const customer_id = req.user.id;

  const { data, error } = await supabaseAdmin
    .from("customer_rewards")
    .select(
      `
      id,
      reward_description,
      status,
      unique_token,
      created_at,
      locations ( name ),
      business_profiles ( business_name )
    `
    )
    .eq("customer_id", customer_id)
    .order("created_at", { ascending: false });

  if (error) {
    return res.status(500).json({ error: error.message });
  }

  const remappedData = data.map((r) => ({
    id: r.id,
    title: r.reward_description,
    business: r.business_profiles?.business_name || "Unknown Business",
    location: r.locations?.name || "Any Location",
    qrData: r.unique_token,
    status: r.status,
    createdAt: r.created_at,
  }));

  res.status(200).json(remappedData);
});

/**
 * VOUCHING & REVIEWS API
 */

app.post("/api/reviews", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const customer_id = req.user.id;
  const { location_id, pop_token, rating, comment } = req.body;

  try {
    const { data: vouch, error: vouchError } = await supabaseAdmin
      .from("loyalty_transactions")
      .select("id, business_id")
      .eq("customer_id", customer_id)
      .eq("location_id", location_id)
      .eq("pop_token", pop_token)
      .limit(1)
      .single();

    if (vouchError || !vouch) {
      return res
        .status(403)
        .json({ error: "Invalid or missing POP token. Cannot verify review." });
    }

    const { data: newReview, error: reviewError } = await supabaseAdmin
      .from("reviews")
      .insert({
        loyalty_transaction_id: vouch.id,
        customer_id,
        location_id,
        business_id: vouch.business_id,
        rating,
        comment,
      })
      .select()
      .single();

    if (reviewError) {
      if (reviewError.code === "23505") {
        return res.status(409).json({
          error: "You have already submitted a review for this vouch.",
        });
      }
      return res.status(500).json({ error: reviewError.message });
    }

    res.status(201).json(newReview);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/vouch/start", authMiddleware, async (req, res) => {
  // ... (this function is unchanged, logs are fine)
  const { location_id } = req.body;
  const customer_id = req.user.id;

  console.log(
    `[VOUCH START] Customer ${customer_id} starting vouch at location ${location_id}`
  );

  try {
    const { error } = await supabaseAdmin
      .from("vouch_attempts")
      .insert(
        { customer_id, location_id, status: "pending" },
        { onConflict: "customer_id, location_id, status" }
      );
    if (error) throw error;

    console.log(`[VOUCH START] ✅ Timer started successfully`);
    res.status(201).json({ message: "Timer started" });
  } catch (error) {
    console.error(`[VOUCH START] ❌ Error:`, error.message);
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/vouch/stop", authMiddleware, async (req, res) => {
  // ... (this function is unchanged, logs are fine)
  const { location_id } = req.body;
  const customer_id = req.user.id;

  console.log(
    `[VOUCH STOP] Customer ${customer_id} stopping vouch at location ${location_id}`
  );

  try {
    const { data: attempt, error: findError } = await supabaseAdmin
      .from("vouch_attempts")
      .select("*, locations(dwell_time_minutes, owner_id)")
      .eq("customer_id", customer_id)
      .eq("location_id", location_id)
      .eq("status", "pending")
      .limit(1)
      .single();

    if (findError || !attempt) {
      console.log(`[VOUCH STOP] ⚠️ No pending vouch found`);
      return res.status(404).json({ error: "No pending vouch found to stop" });
    }

    const startTime = new Date(attempt.start_time);
    const endTime = new Date();
    const durationMs = endTime.getTime() - startTime.getTime();
    const requiredMs = (attempt.locations.dwell_time_minutes || 5) * 60 * 1000;

    console.log(
      `[VOUCH STOP] Duration: ${durationMs}ms, Required: ${requiredMs}ms`
    );

    if (durationMs >= requiredMs) {
      const popToken = crypto.randomBytes(4).toString("hex").toUpperCase();

      console.log(
        `[VOUCH STOP] ✅ Dwell time met! Creating POP token: ${popToken}`
      );

      const { error: vouchError } = await supabaseAdmin
        .from("loyalty_transactions")
        .insert({
          customer_id,
          location_id,
          business_id: attempt.locations.owner_id,
          transaction_type: "earn_vouch",
          points_change: 1,
          pop_token: popToken,
        });

      if (vouchError) {
        console.error(
          `[VOUCH STOP] ❌ Error creating loyalty transaction:`,
          vouchError
        );
        throw vouchError;
      }

      await supabaseAdmin
        .from("vouch_attempts")
        .update({ status: "completed" })
        .eq("id", attempt.id);

      await triggerCampaigns(
        customer_id,
        location_id,
        attempt.locations.owner_id
      );

      console.log(`[VOUCH STOP] 🎉 Vouch completed successfully!`);

      return res.status(200).json({
        message: "Vouch created!",
        status: "completed",
        pop_token: popToken,
      });
    } else {
      console.log(`[VOUCH STOP] ⏱️ Dwell time not met, deleting attempt`);

      await supabaseAdmin.from("vouch_attempts").delete().eq("id", attempt.id);
      return res
        .status(200)
        .json({ message: "Dwell time not met.", status: "failed_duration" });
    }
  } catch (error) {
    console.error(`[VOUCH STOP] ❌ Unexpected error:`, error.message);
    res.status(500).json({ error: error.message });
  }
});

app.get("/api/vouch/status/:location_id", authMiddleware, async (req, res) => {
  // ... (this function is unchanged and has the fix)
  const { location_id } = req.params;
  const customer_id = req.user.id;

  console.log(
    `[VOUCH STATUS] Checking status for customer ${customer_id} at location ${location_id}`
  );

  try {
    const { data: existingVouches, error: vouchError } = await supabaseAdmin
      .from("loyalty_transactions")
      .select("id, pop_token, created_at")
      .eq("customer_id", customer_id)
      .eq("location_id", location_id)
      .eq("transaction_type", "earn_vouch")
      .order("created_at", { ascending: false })
      .limit(1);

    console.log(
      `[VOUCH STATUS] Existing vouches found:`,
      existingVouches?.length || 0
    );

    if (vouchError) {
      console.error(
        `[VOUCH STATUS] Error fetching vouches:`,
        vouchError.message
      );
    }

    if (existingVouches && existingVouches.length > 0) {
      const vouch = existingVouches[0];
      console.log(
        `[VOUCH STATUS] ✅ Returning completed vouch with POP token: ${vouch.pop_token}`
      );
      return res.status(200).json({
        status: "completed",
        pop_token: vouch.pop_token,
      });
    }

    console.log(
      `[VOUCH STATUS] No completed vouch found, checking for pending attempts...`
    );

    const { data: attempts, error: attemptError } = await supabaseAdmin
      .from("vouch_attempts")
      .select("start_time, locations(dwell_time_minutes)")
      .eq("customer_id", customer_id)
      .eq("location_id", location_id)
      .eq("status", "pending")
      .limit(1);

    if (attemptError) {
      console.error(
        `[VOUCH STATUS] Error fetching attempts:`,
        attemptError.message
      );
    }

    console.log(
      `[VOUCH STATUS] Pending attempts found:`,
      attempts?.length || 0
    );

    if (attempts && attempts.length > 0) {
      const attempt = attempts[0];
      const startTime = new Date(attempt.start_time).getTime();
      const dwellTimeMs =
        (attempt.locations.dwell_time_minutes || 5) * 60 * 1000;
      const elapsedTime = new Date().getTime() - startTime;
      const secondsRemaining = Math.max(0, (dwellTimeMs - elapsedTime) / 1000);

      console.log(
        `[VOUCH STATUS] ⏱️ Timer counting: ${secondsRemaining.toFixed(
          1
        )}s remaining`
      );

      return res.status(200).json({
        status: "counting",
        seconds_remaining: secondsRemaining,
        dwell_time_total: dwellTimeMs / 1000,
      });
    }

    console.log(`[VOUCH STATUS] 💤 No vouch or attempt found, returning idle`);
    res.status(200).json({ status: "idle" });
  } catch (error) {
    console.error(`[VOUCH STATUS] ❌ Unexpected error:`, error.message);
    res.status(500).json({ error: error.message });
  }
});

app.post("/api/campaigns", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const {
    reward_id,
    reward_description,
    name,
    description,
    campaign_type,
    target_value,
    location_id,
    start_date,
    end_date,
    is_active,
  } = req.body;

  if (!reward_id || !reward_description || !name) {
    return res
      .status(400)
      .json({ error: "Missing required fields (reward, description, name)." });
  }

  const { data, error } = await supabaseAdmin
    .from("campaigns")
    .insert({
      ...req.body,
      owner_id: req.user.id,
    })
    .select()
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

app.put("/api/campaigns/:id", authMiddleware, async (req, res) => {
  // ... (this function is unchanged)
  const { id } = req.params;
  const {
    reward_id,
    reward_description,
    name,
    description,
    campaign_type,
    target_value,
    location_id,
    start_date,
    end_date,
    is_active,
  } = req.body;

  const { data, error } = await supabaseAdmin
    .from("campaigns")
    .update({
      reward_id,
      reward_description,
      name,
      description,
      campaign_type,
      target_value,
      location_id,
      start_date,
      end_date,
      is_active,
    })
    .eq("id", id)
    .eq("owner_id", req.user.id)
    .select()
    .single();

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
});

app.get("/api/customer/profile", authMiddleware, async (req, res) => {
  const customer_id = req.user.id;

  const { data, error } = await supabaseAdmin
    .from("customers")
    .select("id, name, email, phone, avatar_url")
    .eq("id", customer_id)
    .single();

  if (error) {
    return res.status(500).json({ error: error.message });
  }
  res.status(200).json(data);
});

app.put("/api/customer/profile", authMiddleware, async (req, res) => {
  const customer_id = req.user.id;
  const { name, phone } = req.body;

  const { data, error } = await supabaseAdmin
    .from("customers")
    .update({ name, phone })
    .eq("id", customer_id)
    .select("id, name, email, phone, avatar_url")
    .single();

  if (error) {
    return res.status(500).json({ error: error.message });
  }
  res.status(200).json(data);
});

app.put("/api/customer/avatar-url", authMiddleware, async (req, res) => {
  const customer_id = req.user.id;
  const { avatar_url } = req.body;

  const { data, error } = await supabaseAdmin
    .from("customers")
    .update({ avatar_url })
    .eq("id", customer_id)
    .select("id, name, email, phone, avatar_url")
    .single();

  if (error) {
    return res.status(500).json({ error: error.message });
  }
  res.status(200).json(data);
});

app.listen(port, () => {
  console.log(`✅ Vouch backend server listening on http://localhost:${port}`);
  console.log(`✅ SQL trigger is handling new user signups.`);
});
