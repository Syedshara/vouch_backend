// generate-keys.js
import crypto from "crypto";
import fs from "fs";

const envPath = "./.env";

// 1. Check if keys already exist in .env
try {
  if (fs.existsSync(envPath)) {
    const envContent = fs.readFileSync(envPath, "utf-8");
    if (envContent.includes("SERVER_PRIVATE_KEY")) {
      console.log("✅ Keys already found in .env file. No action needed.");
      console.log("You can now start your server: node index.js");
      process.exit(0); // Exit successfully
    }
  }
} catch (e) {
  console.warn(
    "Could not read .env file, will try to create/append anyway.",
    e.message
  );
}

// 2. If keys don't exist, generate them
console.log("No keys found. Generating new ECC keys...");
const { privateKey, publicKey } = crypto.generateKeyPairSync("ec", {
  namedCurve: "secp256k1",
  publicKeyEncoding: {
    type: "spki",
    format: "pem",
  },
  privateKeyEncoding: {
    type: "pkcs8",
    format: "pem",
  },
});

// 3. Format for .env file (replacing newlines with \n)
const envPrivateKey = privateKey.replace(/\n/g, "\\n");
const envPublicKey = publicKey.replace(/\n/g, "\\n");

// 4. Create the string to append
const keyString = `
# ECC Keys for signing vouchers
SERVER_PRIVATE_KEY="${envPrivateKey}"
SERVER_PUBLIC_KEY="${envPublicKey}"
`;

// 5. Append keys to the .env file
try {
  fs.appendFileSync(envPath, keyString);
  console.log("✅ Successfully generated and saved keys to your .env file!");
  console.log("You can now start your server: node index.js");
} catch (e) {
  console.error("❌ Failed to write keys to .env file:", e.message);
  console.log(
    "Please copy and paste the following lines into your .env file manually:\n"
  );
  console.log(`SERVER_PRIVATE_KEY="${envPrivateKey}"`);
  console.log(`SERVER_PUBLIC_KEY="${envPublicKey}"`);
}
