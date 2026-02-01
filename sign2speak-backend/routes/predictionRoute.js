const express = require("express");
const authMiddleware = require("../middleware/authMiddleware");
const Prediction = require("../models/Prediction");

const router = express.Router();

/**
 * GET /api/predictions/me
 * Fetch predictions of logged-in user
 */
router.get("/predictions/me", authMiddleware, async (req, res) => {
  try {
    const predictions = await Prediction.find({
      user: req.user,
    })
      .sort({ createdAt: -1 })
      .limit(100); // optional safety limit
    res.json({
      success: true,
      count: predictions.length,
      predictions,
    });
  } catch (err) {
    console.error("Fetch predictions error:", err.message);
    res.status(500).json({
      error: "Failed to fetch predictions",
    });
  }
});

module.exports = router;
