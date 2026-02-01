const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const User = require("../models/User");

const router = express.Router();

/**
 * POST /api/users/me/login
 * Creates/updates the user using Firebase token info.
 */
router.post("/me/login", authMiddleware, async (req, res) => {
  const { uid, email, name, picture } = req.firebase;

  if (!email) {
    return res.status(400).json({ message: "Firebase token missing email (check provider)" });
  }

  const user = await User.findOneAndUpdate(
    { firebaseUid: uid },
    {
      $set: {
        firebaseUid: uid,
        email,
        nameFromGoogle: name || "",
        photoURL: picture || "",
        lastLoginAt: new Date(),
      },
    },
    { new: true, upsert: true }
  );

  return res.json({
    message: "Login synced",
    user,
  });
});

/**
 * PUT /api/users/me/profile
 * Saves user-input profile fields.
 */
router.put("/me/profile", authMiddleware, async (req, res) => {
  const { uid } = req.firebase;

  const { name, phoneNumber, dateOfBirth, city, country } = req.body || {};

  // Basic validation (you can tighten this later)
  if (!name || !phoneNumber || !dateOfBirth || !city || !country) {
    return res.status(400).json({
      message: "Missing fields. Required: name, phoneNumber, dateOfBirth, city, country",
    });
  }

  const user = await User.findOneAndUpdate(
    { firebaseUid: uid },
    {
      $set: {
        "profile.name": name,
        "profile.phoneNumber": phoneNumber,
        "profile.dateOfBirth": dateOfBirth,
        "profile.city": city,
        "profile.country": country,
        profileCompleted: true,
      },
    },
    { new: true }
  );

  if (!user) {
    return res.status(404).json({ message: "User not found. Call /me/login first." });
  }

  return res.json({ message: "Profile updated", user });
});

/**
 * GET /api/users/me
 * Returns the current user
 */
router.get("/me", authMiddleware, async (req, res) => {
  const { uid } = req.firebase;

  const user = await User.findOne({ firebaseUid: uid });
  if (!user) return res.status(404).json({ message: "User not found" });

  return res.json({ user });
});

module.exports = router;
