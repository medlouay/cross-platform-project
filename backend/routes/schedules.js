const express = require("express")
const router = express.Router()
const con = require("../db")

// CREATE workout schedule
router.post("/", (req, res) => {
    const {
        user_id,
        workout_id,
        scheduled_date,
        scheduled_time,
        duration,
        difficulty,
        repetitions,
        weights
    } = req.body

    if (!workout_id || !scheduled_date || !scheduled_time) {
        return res.status(400).json({ 
            error: "workout_id, scheduled_date, and scheduled_time are required" 
        })
    }

    const sql = `
        INSERT INTO workout_schedules 
        (user_id, workout_id, scheduled_date, scheduled_time, duration, difficulty, repetitions, weights)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `

    con.query(sql, [
        user_id || null,
        workout_id,
        scheduled_date,
        scheduled_time,
        duration,
        difficulty,
        repetitions,
        weights
    ], (err, result) => {
        if (err) return res.status(500).json({ error: err.message })
        
        res.json({ 
            message: "Workout scheduled successfully",
            schedule_id: result.insertId 
        })
    })
})

// GET all schedules (optionally filter by date range)
router.get("/", (req, res) => {
    const { user_id, start_date, end_date } = req.query
    
    let sql = `
        SELECT 
            ws.*,
            w.name as workout_name,
            w.photo as workout_photo,
            w.description as workout_description
        FROM workout_schedules ws
        LEFT JOIN workouts w ON ws.workout_id = w.id
        WHERE 1=1
    `
    
    const params = []
    
    if (user_id) {
        sql += " AND ws.user_id = ?"
        params.push(user_id)
    }
    
    if (start_date) {
        sql += " AND ws.scheduled_date >= ?"
        params.push(start_date)
    }
    
    if (end_date) {
        sql += " AND ws.scheduled_date <= ?"
        params.push(end_date)
    }
    
    sql += " ORDER BY ws.scheduled_date ASC, ws.scheduled_time ASC"
    
    con.query(sql, params, (err, schedules) => {
        if (err) return res.status(500).json({ error: err.message })
        res.json(schedules)
    })
})

// GET schedules for a specific date
router.get("/date/:date", (req, res) => {
    const { date } = req.params
    const { user_id } = req.query
    
    let sql = `
        SELECT 
            ws.*,
            w.name as workout_name,
            w.photo as workout_photo,
            w.description as workout_description
        FROM workout_schedules ws
        LEFT JOIN workouts w ON ws.workout_id = w.id
        WHERE ws.scheduled_date = ?
    `
    
    const params = [date]
    
    if (user_id) {
        sql += " AND ws.user_id = ?"
        params.push(user_id)
    }
    
    sql += " ORDER BY ws.scheduled_time ASC"
    
    con.query(sql, params, (err, schedules) => {
        if (err) return res.status(500).json({ error: err.message })
        res.json(schedules)
    })
})

// GET single schedule by ID
router.get("/:id", (req, res) => {
    const { id } = req.params
    
    const sql = `
        SELECT 
            ws.*,
            w.name as workout_name,
            w.photo as workout_photo,
            w.description as workout_description,
            w.duration as workout_duration,
            w.difficulty as workout_difficulty
        FROM workout_schedules ws
        LEFT JOIN workouts w ON ws.workout_id = w.id
        WHERE ws.id = ?
    `
    
    con.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message })
        if (result.length === 0) {
            return res.status(404).json({ error: "Schedule not found" })
        }
        res.json(result[0])
    })
})

// UPDATE schedule
router.put("/:id", (req, res) => {
    const { id } = req.params
    const {
        scheduled_date,
        scheduled_time,
        duration,
        difficulty,
        repetitions,
        weights,
        status
    } = req.body
    
    const updates = []
    const params = []
    
    if (scheduled_date) {
        updates.push("scheduled_date = ?")
        params.push(scheduled_date)
    }
    if (scheduled_time) {
        updates.push("scheduled_time = ?")
        params.push(scheduled_time)
    }
    if (duration) {
        updates.push("duration = ?")
        params.push(duration)
    }
    if (difficulty) {
        updates.push("difficulty = ?")
        params.push(difficulty)
    }
    if (repetitions) {
        updates.push("repetitions = ?")
        params.push(repetitions)
    }
    if (weights) {
        updates.push("weights = ?")
        params.push(weights)
    }
    if (status) {
        updates.push("status = ?")
        params.push(status)
        
        // If marking as completed, set completed_at
        if (status === 'completed') {
            updates.push("completed_at = NOW()")
        }
    }
    
    if (updates.length === 0) {
        return res.status(400).json({ error: "No fields to update" })
    }
    
    params.push(id)
    const sql = `UPDATE workout_schedules SET ${updates.join(", ")} WHERE id = ?`
    
    con.query(sql, params, (err, result) => {
        if (err) return res.status(500).json({ error: err.message })
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: "Schedule not found" })
        }
        res.json({ message: "Schedule updated successfully" })
    })
})

// MARK as completed
router.post("/:id/complete", (req, res) => {
    const { id } = req.params
    
    const sql = `
        UPDATE workout_schedules 
        SET status = 'completed', completed_at = NOW() 
        WHERE id = ?
    `
    
    con.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message })
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: "Schedule not found" })
        }
        res.json({ message: "Workout marked as completed" })
    })
})

// DELETE schedule
router.delete("/:id", (req, res) => {
    const { id } = req.params
    
    const sql = "DELETE FROM workout_schedules WHERE id = ?"
    
    con.query(sql, [id], (err, result) => {
        if (err) return res.status(500).json({ error: err.message })
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: "Schedule not found" })
        }
        res.json({ message: "Schedule deleted successfully" })
    })
})

module.exports = router