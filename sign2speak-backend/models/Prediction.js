const mongoose = require("mongoose");

const PredictionSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    sign: {
      type: String,
      required: true,
    },

    confidence: {
      type: Number,
      required: true,
    },

    source: {
      type: String,
      enum: ["video", "image"],
      default: "video",
    },

    meta: {
      type: Object, // optional (camera, fps, etc)
      default: {},
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Prediction", PredictionSchema);
