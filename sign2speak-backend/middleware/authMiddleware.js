const admin = require("../config/firebaseAdmin");
const User = require("../models/User");

module.exports = async function authMiddleware(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ message: "Missing Bearer token" });
    }

    const token = authHeader.split(" ")[1];

    // 🔐 Verify Firebase token
    const decoded = await admin.auth().verifyIdToken(token);

    // 🔍 Find user in DB
    let user = await User.findOne({ firebaseUid: decoded.uid });

    // 🆕 AUTO-CREATE USER IF NOT FOUND
    if (!user) {
      user = await User.create({
        firebaseUid: decoded.uid,
        email: decoded.email,
        nameFromGoogle: decoded.name || "",
        photoURL: decoded.picture || "",
        profileCompleted: false,
      });

      console.log("🆕 User auto-created:", user.email);
    }

    req.firebase = decoded;
    req.user = user;

    next();
  } catch (err) {
    console.error("AUTH ERROR:", err);
    return res.status(401).json({
      message: "Invalid/expired token",
      error: err.message,
    });
  }
};
