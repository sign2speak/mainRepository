const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    firebaseUid: { type: String, required: true, unique: true, index: true },

    // Google fields
    email: { type: String, required: true, index: true },
    nameFromGoogle: { type: String, default: "" },
    photoURL: { type: String, default: "" },

    // User-input fields (ProfileDetailsScreen)
    profile: {
      name: { type: String, default: "" },
      phoneNumber: { type: String, default: "" },
      dateOfBirth: { type: String, default: "" }, // store as ISO string "YYYY-MM-DD" or full ISO
      city: { type: String, default: "" },
      country: { type: String, default: "" },
    },

    // Useful metadata
    lastLoginAt: { type: Date, default: null },
    profileCompleted: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
