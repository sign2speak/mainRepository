const admin = require("firebase-admin");
const serviceAccount = require("../serviceAccount.json"); // adjust name if needed

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: serviceAccount.project_id, // 🔥 EXPLICIT
  });

  console.log(
    "✅ Firebase Admin initialized for project:",
    serviceAccount.project_id
  );
}

module.exports = admin;
