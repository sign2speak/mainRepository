const express = require("express");
const multer = require("multer");
const fs = require("fs");
const axios = require("axios");
const FormData = require("form-data");

const authMiddleware = require("../middleware/authMiddleware");
const Prediction = require("../models/Prediction");

const router = express.Router();
const upload = multer({ dest: "uploads/" });

router.post(
  "/predict",
  authMiddleware,
  upload.single("video"),
  async (req, res) => {
    let videoPath = null;

    try {
      // 1️⃣ Validate upload
      if (!req.file) {
        return res.status(400).json({ error: "No video uploaded" });
      }

      videoPath = req.file.path;

      // 2️⃣ Forward video to Python ML service
      const form = new FormData();
      form.append("video", fs.createReadStream(videoPath));
console.log("➡️ About to call Python ML service...");

const response = await axios.post(
  "http://127.0.0.1:8000/predict",
  form,
  {
    headers: form.getHeaders(),
    timeout: 30000,
  }
);


      console.log("🔮 ML Response:", response.data);

      const { sign, confidence } = response.data;

      // 3️⃣ Save prediction against logged-in user
      const prediction = await Prediction.create({
        user: req.user._id,   
        sign,
        confidence,
        source: "video",
      });

      console.log(
        `✅ Prediction saved | User: ${req.user.email} | Sign: ${sign}`
      );

      // 4️⃣ Cleanup uploaded video
      fs.unlinkSync(videoPath);

      // 5️⃣ Respond to client
      return res.json({
        success: true,
        sign,
        confidence,
        predictionId: prediction._id,
      });

    } catch (err) {
      console.error("========== SIGN2SPEAK ERROR ==========");
      console.error(err.response?.data || err.message);
      console.error("=====================================");

      if (videoPath && fs.existsSync(videoPath)) {
        fs.unlinkSync(videoPath);
      }

      return res.status(500).json({
        error: "Sign prediction failed",
        details: err.response?.data || err.message,
      });
    }
  }
);

module.exports = router;
