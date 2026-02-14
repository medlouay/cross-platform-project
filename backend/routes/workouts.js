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

    const ext = matches[1].split("/")[1]
    const data = matches[2]
    const filename = Date.now() + "." + ext
    const dir = "./uploads"
    if (!fs.existsSync(dir)) fs.mkdirSync(dir)
    fs.writeFileSync(path.join(dir, filename), Buffer.from(data, "base64"))
    return filename
}

// CREATE workout with base64 photo
router.post("/", (req, res) => {
    const {
        name,
        description,
        duration,
        difficulty,
        muscle_groups,
        photo_base64,
        materials,
        sets
    } = req.body

    if (!name) return res.status(400).json({ error: "Name is required" })

    const photo = saveBase64Image(photo_base64)

    const workoutSql = `
        INSERT INTO workouts 
        (name, description, photo, duration, difficulty, muscle_groups)
        VALUES (?, ?, ?, ?, ?, ?)
    `

    con.query(workoutSql,
        [name, description, photo, duration, difficulty, muscle_groups],
        (err, result) => {
            if (err) return res.status(500).json({ error: err })

            const workoutId = result.insertId

            // Insert materials
            if (materials && materials.length > 0) {
                materials.forEach(mat => {
                    const materialImage = saveBase64Image(mat.image_base64)
                    const sql = `
                        INSERT INTO materials (workout_id, title, image)
                        VALUES (?, ?, ?)
                    `
                    con.query(sql, [workoutId, mat.title, materialImage])
                })
            }

            // Insert sets and exercises
            if (sets && sets.length > 0) {
                sets.forEach(set => {
                    const setSql = `
                        INSERT INTO workout_sets (workout_id, name)
                        VALUES (?, ?)
                    `
                    con.query(setSql, [workoutId, set.name], (err, setResult) => {
                        const setId = setResult.insertId

                        if (set.exercises) {
                            set.exercises.forEach(ex => {
                                const exerciseImage = saveBase64Image(ex.image_base64)
                                const exSql = `
                                    INSERT INTO exercises (set_id, title, value, image)
                                    VALUES (?, ?, ?, ?)
                                `
                                con.query(exSql, [
                                    setId,
                                    ex.title,
                                    ex.value,
                                    exerciseImage
                                ], (err, exResult) => {
                                    if (err) return
                                    
                                    const exerciseId = exResult.insertId

                                    // 🔹 Insert exercise steps
                                    if (ex.steps && ex.steps.length > 0) {
                                        ex.steps.forEach((step, index) => {
                                            const stepSql = `
                                                INSERT INTO exercise_steps 
                                                (exercise_id, step_number, title, description)
                                                VALUES (?, ?, ?, ?)
                                            `
                                            con.query(stepSql, [
                                                exerciseId,
                                                step.step_number || (index + 1),
                                                step.title,
                                                step.description
                                            ])
                                        })
                                    }
                                })
                            })
                        }
                    })
                })
            }

            res.json({ message: "Workout created with sets, materials & exercise steps" })
        }
    )
})

// LIST workouts
router.get("/", (req, res) => {
    const workoutSql = "SELECT * FROM workouts ORDER BY created_at DESC"

    con.query(workoutSql, (err, workouts) => {
        if (err) return res.status(500).json({ error: err })

        if (workouts.length === 0) return res.json([])

        let completed = 0

        workouts.forEach((workout, index) => {
            // Get materials
            con.query(
                "SELECT * FROM materials WHERE workout_id = ?",
                [workout.id],
                (err, materials) => {
                    // Get sets
                    con.query(
                        "SELECT * FROM workout_sets WHERE workout_id = ?",
                        [workout.id],
                        (err, sets) => {
                            if (!sets.length) {
                                workouts[index].materials = materials
                                workouts[index].sets = []
                                completed++
                                if (completed === workouts.length)
                                    return res.json(workouts)
                            } else {
                                let setCompleted = 0

                                sets.forEach((set, setIndex) => {
                                    con.query(
                                        "SELECT * FROM exercises WHERE set_id = ?",
                                        [set.id],
                                        (err, exercises) => {
                                            sets[setIndex].exercises = exercises
                                            setCompleted++

                                            if (setCompleted === sets.length) {
                                                workouts[index].materials = materials
                                                workouts[index].sets = sets
                                                completed++

                                                if (completed === workouts.length)
                                                    res.json(workouts)
                                            }
                                        }
                                    )
                                })
                            }
                        }
                    )
                }
            )
        })
    })
})

// GET single workout by ID with all details including exercise steps
router.get("/:id", (req, res) => {
    const { id } = req.params

    const workoutSql = "SELECT * FROM workouts WHERE id = ?"

    con.query(workoutSql, [id], (err, workoutResult) => {
        if (err) return res.status(500).json({ error: err })
        if (workoutResult.length === 0)
            return res.status(404).json({ error: "Workout not found" })

        const workout = workoutResult[0]

        // Get materials
        con.query("SELECT * FROM materials WHERE workout_id = ?", [id], (err, materials) => {
            // Get sets
            con.query("SELECT * FROM workout_sets WHERE workout_id = ?", [id], (err, sets) => {
                if (!sets.length) {
                    return res.json({ ...workout, materials, sets: [] })
                }

                let setsCompleted = 0

                sets.forEach((set, setIndex) => {
                    con.query("SELECT * FROM exercises WHERE set_id = ?", [set.id], (err, exercises) => {
                        
                        if (!exercises.length) {
                            sets[setIndex].exercises = []
                            setsCompleted++
                            
                            if (setsCompleted === sets.length) {
                                res.json({
                                    ...workout,
                                    materials,
                                    sets
                                })
                            }
                        } else {
                            let exercisesCompleted = 0

                            // 🔹 Get steps for each exercise
                            exercises.forEach((exercise, exIndex) => {
                                con.query(
                                    "SELECT * FROM exercise_steps WHERE exercise_id = ? ORDER BY step_number",
                                    [exercise.id],
                                    (err, steps) => {
                                        exercises[exIndex].steps = steps || []
                                        exercisesCompleted++

                                        if (exercisesCompleted === exercises.length) {
                                            sets[setIndex].exercises = exercises
                                            setsCompleted++

                                            if (setsCompleted === sets.length) {
                                                res.json({
                                                    ...workout,
                                                    materials,
                                                    sets
                                                })
                                            }
                                        }
                                    }
                                )
                            })
                        }
                    })
                })
            })
        })
    })
})

// GET single exercise by ID with steps
router.get("/exercise/:id", (req, res) => {
    const { id } = req.params

    const exerciseSql = "SELECT * FROM exercises WHERE id = ?"

    con.query(exerciseSql, [id], (err, exerciseResult) => {
        if (err) return res.status(500).json({ error: err })
        if (exerciseResult.length === 0)
            return res.status(404).json({ error: "Exercise not found" })

        const exercise = exerciseResult[0]

        // Get steps for this exercise
        con.query(
            "SELECT * FROM exercise_steps WHERE exercise_id = ? ORDER BY step_number",
            [id],
            (err, steps) => {
                if (err) return res.status(500).json({ error: err })
                
                res.json({
                    ...exercise,
                    steps: steps || []
                })
            }
        )
    })
})

router.delete("/:id", (req, res) => {
    const { id } = req.params

    const selectSql = "SELECT photo FROM workouts WHERE id = ?"

    con.query(selectSql, [id], (err, results) => {
        if (err) return res.status(500).json({ error: err })

        if (results.length === 0)
            return res.status(404).json({ error: "Workout not found" })

        const photo = results[0].photo

        const deleteSql = "DELETE FROM workouts WHERE id = ?"

        con.query(deleteSql, [id], (err) => {
            if (err) return res.status(500).json({ error: err })

            if (photo) {
                const filePath = `./uploads/${photo}`
                if (fs.existsSync(filePath)) {
                    fs.unlinkSync(filePath)
                }
            }

            res.json({
                message: "Workout and all related data deleted successfully"
            })
        })
    })
})

module.exports = router