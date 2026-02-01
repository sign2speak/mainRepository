require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const inferenceRoute = require("./routes/inference");
const predictionRoutes = require("./routes/predictionRoute")
const userRoutes = require("./routes/userRoutes");

const app = express();

app.get("/ping", (req, res) => {
  console.log("PING RECEIVED");
  res.json({ ok: true });
});


app.use("/api", inferenceRoute);
app.use(cors());
app.use(express.json({ limit: "2mb" }));
app.use("/api/fetchPredictions", predictionRoutes);

app.get("/", (req, res) => res.send("✅ Sign2Speak backend running"));

app.use("/api/users", userRoutes);

const PORT = process.env.PORT || 5000;

connectDB()
  .then(() => {
    app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server running on port ${PORT}`);
});

  })
  .catch((err) => {
    console.error("❌ DB connection error:", err);
    process.exit(1);
  });
