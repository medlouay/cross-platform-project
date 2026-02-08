const express = require("express")
const router = express.Router()
const path = require("path")
const fs = require("fs")
const con = require("../db")

// Serve uploads folder
router.use("/uploads", express.static(path.join(__dirname, "../uploads")))

// Helper to save base64 image
function saveBase64Image(base64Data) {
    if (!base64Data) return null
    const matches = base64Data.match(/^data:(image\/\w+);base64,(.+)$/)
    if (!matches) return null

    const ext = matches[1].split("/")[1] // get image extension
    const data = matches[2]
    const filename = Date.now() + "." + ext
    const dir = "./uploads"
    if (!fs.existsSync(dir)) fs.mkdirSync(dir)
    fs.writeFileSync(path.join(dir, filename), Buffer.from(data, "base64"))
    return filename
}

// CREATE workout with base64 photo
router.post("/", (req, res) => {
    const { name, description, duration, difficulty, muscle_groups, photo_base64 } = req.body
    const photo = saveBase64Image(photo_base64)

    if (!name) return res.status(400).json({ error: "Name is required" })

    const sql = `
        INSERT INTO workouts 
        (name, description, photo, duration, difficulty, muscle_groups)
        VALUES (?, ?, ?, ?, ?, ?)
    `
    con.query(sql, [name, description, photo, duration, difficulty, muscle_groups], (err, result) => {
        if (err) return res.status(500).json({ error: err })
        res.json({ message: "Workout created", id: result.insertId })
    })
})

// LIST workouts
router.get("/", (req, res) => {
    const sql = "SELECT * FROM workouts ORDER BY created_at DESC"
    con.query(sql, (err, results) => {
        if (err) return res.status(500).json({ error: err })
        res.json(results)
    })
})

router.get("/:id", (req, res) => {
    const { id } = req.params

    const sql = "SELECT * FROM workouts WHERE id = ?"
    con.query(sql, [id], (err, results) => {
        if (err) return res.status(500).json({ error: err })
        if (results.length === 0) return res.status(404).json({ error: "Workout not found" })
        res.json(results[0])
    })
})

router.delete("/:id", (req, res) => {
    const { id } = req.params

    // First, get the workout to find its photo
    const selectSql = "SELECT * FROM workouts WHERE id = ?"
    con.query(selectSql, [id], (err, results) => {
        if (err) return res.status(500).json({ error: err })
        if (results.length === 0) return res.status(404).json({ error: "Workout not found" })

        const workout = results[0]

        // Delete the workout from DB
        const deleteSql = "DELETE FROM workouts WHERE id = ?"
        con.query(deleteSql, [id], (err, result) => {
            if (err) return res.status(500).json({ error: err })

            // Delete the photo file if it exists
            if (workout.photo) {
                const filePath = `./uploads/${workout.photo}`
                if (fs.existsSync(filePath)) fs.unlinkSync(filePath)
            }

            res.json({ message: "Workout deleted successfully" })
        })
    })
})

module.exports = router
