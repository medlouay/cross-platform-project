require('dotenv').config(); // ← ADDED THIS LINE
const express = require("express")
const app = express()
const workoutsRoutes = require("./routes/workouts")
const schedulesRoutes = require("./routes/schedules")
const authRoutes = require("./routes/auth")
const galleryRoutes = require("./routes/gallery")
const profileRoutes = require("./routes/profile");
const contactRoutes = require('./routes/contact');
const healthRoutes = require("./routes/health")
const dashboardRoutes = require("./routes/dashboard")
// Increase body size limit to 10MB (or adjust as needed)
app.use(express.json({ limit: "10mb" }))
app.use(express.urlencoded({ limit: "10mb", extended: true }))
app.use("/uploads", express.static("uploads"));
app.use('/contact', contactRoutes);
app.use("/health", healthRoutes)
app.use("/dashboard", dashboardRoutes)
// Use authentication API under /auth
app.use("/auth", authRoutes)

// Use workouts API under /workouts
app.use("/workouts", workoutsRoutes)
app.use("/schedules", schedulesRoutes)
app.use("/gallery", galleryRoutes)
app.use("/profile", profileRoutes);

app.listen(3000, '0.0.0.0' ,() => {
    console.log("Server running on port 3000")
})