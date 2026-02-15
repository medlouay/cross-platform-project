const express = require("express")
const app = express()
const workoutsRoutes = require("./routes/workouts")
const schedulesRoutes = require("./routes/schedules")
const authRoutes = require("./routes/auth")
const galleryRoutes = require("./routes/gallery")

// Increase body size limit to 10MB (or adjust as needed)
app.use(express.json({ limit: "10mb" }))
app.use(express.urlencoded({ limit: "10mb", extended: true }))

// Use authentication API under /auth
app.use("/auth", authRoutes)

// Use workouts API under /workouts
app.use("/workouts", workoutsRoutes)
app.use("/schedules", schedulesRoutes)
app.use("/gallery", galleryRoutes)

app.listen(3000, () => {
    console.log("Server running on port 3000")
})
