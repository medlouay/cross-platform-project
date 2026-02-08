const express = require("express")
const app = express()
const workoutsRoutes = require("./routes/workouts")

// Increase body size limit to 10MB (or adjust as needed)
app.use(express.json({ limit: "10mb" }))
app.use(express.urlencoded({ limit: "10mb", extended: true }))

// Use workouts API under /workouts
app.use("/workouts", workoutsRoutes)

app.listen(3000, () => {
    console.log("Server running on port 3000")
})
