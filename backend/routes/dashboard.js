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

// GET /dashboard/summary?user_id=1&date=YYYY-MM-DD
router.get("/summary", (req, res) => {
    const { user_id, date } = req.query
    if (!user_id) {
        return res.status(400).json({ error: "user_id is required" })
    }

    const day = date || getTodayDateString()

    const totalsSql = `
        SELECT
            SUM(steps) AS steps,
            SUM(calories) AS calories,
            SUM(distance_m) AS distance_m,
            SUM(active_minutes) AS active_minutes,
            SUM(sleep_minutes) AS sleep_minutes,
            SUM(water_ml) AS water_ml,
            AVG(heart_rate_avg) AS heart_rate_avg,
            MIN(heart_rate_min) AS heart_rate_min,
            MAX(heart_rate_max) AS heart_rate_max,
            AVG(weight_kg) AS weight_kg,
            AVG(bmi) AS bmi
        FROM health_daily
        WHERE user_id = ? AND date = ?
    `

    const heartRateSql = `
        SELECT recorded_at, value
        FROM health_samples
        WHERE user_id = ?
          AND metric = 'heart_rate'
          AND DATE(recorded_at) = ?
        ORDER BY recorded_at DESC
        LIMIT 30
    `

    const weeklyStepsSql = `
        SELECT date, SUM(steps) AS steps
        FROM health_daily
        WHERE user_id = ?
          AND date BETWEEN DATE_SUB(?, INTERVAL 6 DAY) AND ?
        GROUP BY date
        ORDER BY date ASC
    `

    con.query(totalsSql, [user_id, day], (err, totalsRows) => {
        if (err) return res.status(500).json({ error: err })

        con.query(heartRateSql, [user_id, day], (err, hrRows) => {
            if (err) return res.status(500).json({ error: err })

            con.query(weeklyStepsSql, [user_id, day, day], (err, weeklyRows) => {
                if (err) return res.status(500).json({ error: err })

                const totals = totalsRows && totalsRows[0] ? totalsRows[0] : {}
                const heartRateSeries = (hrRows || []).reverse()

                res.json({
                    date: day,
                    totals,
                    heart_rate_series: heartRateSeries,
                    weekly_steps: weeklyRows || []
                })
            })
        })
    })
})

module.exports = router
