const express = require("express")
const router = express.Router()
const con = require("../db")

function getTodayDateString() {
    const now = new Date()
    const year = now.getFullYear()
    const month = String(now.getMonth() + 1).padStart(2, "0")
    const day = String(now.getDate()).padStart(2, "0")
    return `${year}-${month}-${day}`
}

// POST /health/ingest
// Periodic uploads from device sensors / smartwatches
router.post("/ingest", (req, res) => {
    const {
        user_id,
        device_uuid,
        source,
        platform,
        model,
        date,
        timezone,
        aggregates,
        samples
    } = req.body

    if (!user_id || !device_uuid || !source) {
        return res.status(400).json({
            error: "user_id, device_uuid, and source are required"
        })
    }

    const day = date || getTodayDateString()

    const deviceSql = `
        INSERT INTO devices (user_id, device_uuid, source, platform, model, last_seen_at)
        VALUES (?, ?, ?, ?, ?, NOW())
        ON DUPLICATE KEY UPDATE
            source = VALUES(source),
            platform = VALUES(platform),
            model = VALUES(model),
            last_seen_at = NOW()
    `

    con.query(
        deviceSql,
        [user_id, device_uuid, source, platform || null, model || null],
        (err, result) => {
            if (err) return res.status(500).json({ error: err })

            const fetchDeviceId = (callback) => {
                if (result.insertId && result.insertId > 0) {
                    return callback(null, result.insertId)
                }
                con.query(
                    "SELECT id FROM devices WHERE user_id = ? AND device_uuid = ?",
                    [user_id, device_uuid],
                    (err, rows) => {
                        if (err) return callback(err)
                        if (!rows || rows.length === 0)
                            return callback(new Error("Device not found"))
                        callback(null, rows[0].id)
                    }
                )
            }

            fetchDeviceId((err, deviceId) => {
                if (err) return res.status(500).json({ error: err.message })

                const agg = aggregates || {}

                const dailySql = `
                    INSERT INTO health_daily
                    (user_id, device_id, source, date, timezone, steps, calories, distance_m,
                     active_minutes, sleep_minutes, heart_rate_avg, heart_rate_min, heart_rate_max,
                     water_ml, weight_kg, bmi)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        timezone = VALUES(timezone),
                        steps = VALUES(steps),
                        calories = VALUES(calories),
                        distance_m = VALUES(distance_m),
                        active_minutes = VALUES(active_minutes),
                        sleep_minutes = VALUES(sleep_minutes),
                        heart_rate_avg = VALUES(heart_rate_avg),
                        heart_rate_min = VALUES(heart_rate_min),
                        heart_rate_max = VALUES(heart_rate_max),
                        water_ml = VALUES(water_ml),
                        weight_kg = VALUES(weight_kg),
                        bmi = VALUES(bmi),
                        updated_at = CURRENT_TIMESTAMP
                `

                const dailyParams = [
                    user_id,
                    deviceId,
                    source,
                    day,
                    timezone || null,
                    agg.steps ?? null,
                    agg.calories ?? null,
                    agg.distance_m ?? null,
                    agg.active_minutes ?? null,
                    agg.sleep_minutes ?? null,
                    agg.heart_rate_avg ?? null,
                    agg.heart_rate_min ?? null,
                    agg.heart_rate_max ?? null,
                    agg.water_ml ?? null,
                    agg.weight_kg ?? null,
                    agg.bmi ?? null
                ]

                con.query(dailySql, dailyParams, (err) => {
                    if (err) return res.status(500).json({ error: err })

                        console.log(samples , Array.isArray(samples) )
                    if (!samples || !Array.isArray(samples) || samples.length === 0) {
                        return res.json({ message: "Ingested aggregates only" })
                    }

                    const rows = samples
                        .filter(s => s && s.metric && s.value != null && s.recorded_at)
                        .map(s => [
                            user_id,
                            deviceId,
                            source,
                            s.metric,
                            s.value,
                            s.unit || null,
                            s.recorded_at
                        ])

                    if (rows.length === 0) {
                                                console.log('enter 2')

                        return res.json({ message: "Ingested aggregates only" })
                    }

                    const samplesSql = `
                        INSERT INTO health_samples
                        (user_id, device_id, source, metric, value, unit, recorded_at)
                        VALUES ?
                    `

                    con.query(samplesSql, [rows], (err) => {
                        if (err) return res.status(500).json({ error: err })
                        res.json({ message: "Ingested aggregates and samples" })
                    })
                })
            })
        }
    )
})

// GET /health/daily?user_id=1&date=YYYY-MM-DD
router.get("/daily", (req, res) => {
    const { user_id, date } = req.query
    if (!user_id || !date) {
        return res.status(400).json({ error: "user_id and date are required" })
    }

    const sql = `
        SELECT *
        FROM health_daily
        WHERE user_id = ? AND date = ?
        ORDER BY updated_at DESC
    `
    con.query(sql, [user_id, date], (err, rows) => {
        if (err) return res.status(500).json({ error: err })
        res.json(rows)
    })
})

module.exports = router
