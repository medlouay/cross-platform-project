const express = require("express")
const router = express.Router()
const con = require("../db")
const path = require("path")
const fs = require("fs")

router.use("/uploads", express.static(path.join(__dirname, "../uploads")))



function saveBase64Image(base64Data) {
    if (!base64Data) return null
    const matches = base64Data.match(/^data:(image\/\w+);base64,(.+)$/)
    if (!matches) return null

    const ext = matches[1].split("/")[1]
    const data = matches[2]
    const filename = Date.now() + "." + ext
    const dir = path.join(__dirname, "../uploads")

    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
    fs.writeFileSync(path.join(dir, filename), Buffer.from(data, "base64"))

    return filename
}

function formatDisplayDate(dateValue) {
    const date = new Date(dateValue)
    return date.toLocaleDateString("en-US", {
        day: "numeric",
        month: "long"
    })
}

router.get("/", (req, res) => {
    const { user_id } = req.query
    let sql = "SELECT * FROM progress_photos"
    const params = []

    if (user_id) {
        sql += " WHERE user_id = ?"
        params.push(user_id)
    }

    sql += " ORDER BY taken_at DESC, id DESC"

    con.query(sql, params, (err, rows) => {
        if (err) return res.status(500).json({ error: err.message })

        const host = `${req.protocol}://${req.get("host")}`
        const groupsByDate = {}

        rows.forEach((row) => {
            const key = String(row.taken_at).slice(0, 10)
            if (!groupsByDate[key]) groupsByDate[key] = []
            groupsByDate[key].push(`${host}/gallery/uploads/${row.photo}`)
        })

        const groups = Object.keys(groupsByDate).map((key) => ({
            time: formatDisplayDate(key),
            photo: groupsByDate[key]
        }))

        const nextDate = new Date()
        nextDate.setDate(nextDate.getDate() + 30)
        const nextPhotoDate = nextDate.toISOString().slice(0, 10)
        const nextLabel = nextDate.toLocaleDateString("en-US", {
            month: "long",
            day: "2-digit"
        })

        res.json({
            reminder: `Next Photos Fall On ${nextLabel}`,
            next_photo_date: nextPhotoDate,
            groups
        })
    })
})

router.post("/", (req, res) => {
    const { user_id, photo_base64, taken_at } = req.body

    if (!photo_base64) {
        return res.status(400).json({ error: "photo_base64 is required" })
    }

    const filename = saveBase64Image(photo_base64)
    if (!filename) {
        return res.status(400).json({ error: "Invalid base64 image format" })
    }

    const takenAt = taken_at || new Date().toISOString().slice(0, 10)
    const sql = "INSERT INTO progress_photos (user_id, photo, taken_at) VALUES (?, ?, ?)"

    con.query(sql, [user_id || null, filename, takenAt], (err, result) => {
        if (err) return res.status(500).json({ error: err.message })

        res.status(201).json({
            message: "Photo added successfully",
            id: result.insertId,
            photo: filename,
            taken_at: takenAt
        })
    })
})

router.delete("/:id", (req, res) => {
    const { id } = req.params
    const selectSql = "SELECT photo FROM progress_photos WHERE id = ?"

    con.query(selectSql, [id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message })
        if (!rows.length) return res.status(404).json({ error: "Photo not found" })

        const photoName = rows[0].photo
        con.query("DELETE FROM progress_photos WHERE id = ?", [id], (delErr) => {
            if (delErr) return res.status(500).json({ error: delErr.message })

            const filePath = path.join(__dirname, "../uploads", photoName)
            if (fs.existsSync(filePath)) fs.unlinkSync(filePath)

            res.json({ message: "Photo deleted successfully" })
        })
    })
})

module.exports = router
