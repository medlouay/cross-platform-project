const express = require("express")
const router = express.Router()
const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")
const con = require("../db")

// Secret key for JWT - use environment variable in production
const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key_change_this"

// REGISTER - Create new user
router.post("/register", (req, res) => {
    const { first_name, last_name, email, password, confirmPassword, phone_number, gender } = req.body

    // Validation
    if (!first_name || !last_name || !email || !password || !confirmPassword) {
        return res.status(400).json({ error: "First name, last name, email, and password are required" })
    }

    if (password !== confirmPassword) {
        return res.status(400).json({ error: "Passwords do not match" })
    }

    if (password.length < 6) {
        return res.status(400).json({ error: "Password must be at least 6 characters" })
    }

    // Check if user already exists
    const checkSql = "SELECT * FROM users WHERE email = ?"
    con.query(checkSql, [email], (err, results) => {
        if (err) return res.status(500).json({ error: "Database error" })

        if (results.length > 0) {
            return res.status(400).json({ error: "Email already registered" })
        }

        // Hash password
        bcrypt.hash(password, 10, (err, hashedPassword) => {
            if (err) return res.status(500).json({ error: "Error hashing password" })

            // Insert user into database
            const insertSql = "INSERT INTO users (first_name, last_name, email, password, phone_number, gender) VALUES (?, ?, ?, ?, ?, ?)"
            con.query(insertSql, [first_name, last_name, email, hashedPassword, phone_number, gender], (err, result) => {
                if (err) return res.status(500).json({ error: "Error creating user" })

                res.status(201).json({
                    message: "User registered successfully",
                    userId: result.insertId,
                    email: email
                })
            })
        })
    })
})

// LOGIN - Authenticate user
router.post("/login", (req, res) => {
    const { email, password } = req.body

    // Validation
    if (!email || !password) {
        return res.status(400).json({ error: "Email and password are required" })
    }

    // Find user by email
    const sql = "SELECT * FROM users WHERE email = ?"
    con.query(sql, [email], (err, results) => {
        if (err) return res.status(500).json({ error: "Database error" })

        if (results.length === 0) {
            return res.status(401).json({ error: "Invalid email or password" })
        }

        const user = results[0]

        // Compare passwords
        bcrypt.compare(password, user.password, (err, isPasswordValid) => {
            if (err) return res.status(500).json({ error: "Error verifying password" })

            if (!isPasswordValid) {
                return res.status(401).json({ error: "Invalid email or password" })
            }

            // Generate JWT token
            const token = jwt.sign(
                { userId: user.id, email: user.email },
                JWT_SECRET,
                { expiresIn: "7d" }
            )

            res.json({
                message: "Login successful",
                userId: user.id,
                first_name: user.first_name,
                last_name: user.last_name,
                email: user.email,
                phone_number: user.phone_number,
                gender: user.gender,
                token: token
            })
        })
    })
})

module.exports = router;
