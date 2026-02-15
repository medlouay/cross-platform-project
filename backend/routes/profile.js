const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const con = require("../db");

const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key_change_this";

// GET user profile (first_name, last_name, email, height, weight, age)
router.get("/", (req, res) => {
    console.log("Profile GET endpoint hit");
    
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return res.status(401).json({ error: "Authorization header missing" });
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
        return res.status(401).json({ error: "Token missing" });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        console.log("Token decoded, userId:", decoded.userId);
        
        const sql = "SELECT first_name, last_name, email, height, weight, age FROM users WHERE id = ?";
        con.query(sql, [decoded.userId], (err, results) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Database error" });
            }
            
            if (results.length === 0) {
                return res.status(404).json({ error: "User not found" });
            }
            
            const user = results[0];
            console.log("Returning user data:", user);
            
            res.json({
                first_name: user.first_name,
                last_name: user.last_name,
                email: user.email,
                phone_number: user.phone_number,
                height: user.height,
                weight: user.weight,
                age: user.age
            });
        });
    } catch (err) {
        console.error("Token verification error:", err);
        return res.status(401).json({ error: "Invalid token" });
    }
});

// PUT - Update user profile (height, weight, age)
router.put("/", (req, res) => {
    console.log("Profile PUT endpoint hit");
    
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return res.status(401).json({ error: "Authorization header missing" });
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
        return res.status(401).json({ error: "Token missing" });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const { height, weight, age } = req.body;
        
        console.log("Updating profile for userId:", decoded.userId);
        console.log("Data:", { height, weight, age });

        // Validation
        if (height && (height < 50 || height > 300)) {
            return res.status(400).json({ error: "Height must be between 50 and 300 cm" });
        }
        if (weight && (weight < 20 || weight > 500)) {
            return res.status(400).json({ error: "Weight must be between 20 and 500 kg" });
        }
        if (age && (age < 1 || age > 150)) {
            return res.status(400).json({ error: "Age must be between 1 and 150" });
        }

        const sql = "UPDATE users SET height = ?, weight = ?, age = ? WHERE id = ?";
        con.query(sql, [height, weight, age, decoded.userId], (err, result) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Database error" });
            }
            
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: "User not found" });
            }
            
            console.log("Profile updated successfully");
            res.json({
                message: "Profile updated successfully",
                height: height,
                weight: weight,
                age: age
            });
        });
    } catch (err) {
        console.error("Token verification error:", err);
        return res.status(401).json({ error: "Invalid token" });
    }
});

router.patch("/personal-data", (req, res) => {
    console.log("Personal data PATCH endpoint hit");
    
    const authHeader = req.headers.authorization;
    if (!authHeader) {
        return res.status(401).json({ error: "Authorization header missing" });
    }

    const token = authHeader.split(" ")[1];
    if (!token) {
        return res.status(401).json({ error: "Token missing" });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const { first_name, last_name, email, phone_number } = req.body;
        
        console.log("Updating personal data for userId:", decoded.userId);
        console.log("Data:", { first_name, last_name, email, phone_number });

        // Validation
        if (!first_name || !last_name || !email) {
            return res.status(400).json({ error: "First name, last name, and email are required" });
        }

        // Email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ error: "Invalid email format" });
        }

        // Check if email already exists for another user
        const checkEmailSql = "SELECT id FROM users WHERE email = ? AND id != ?";
        con.query(checkEmailSql, [email, decoded.userId], (err, results) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Database error" });
            }
            
            if (results.length > 0) {
                return res.status(400).json({ error: "Email already in use by another account" });
            }

            // Update personal data
            const sql = "UPDATE users SET first_name = ?, last_name = ?, email = ?, phone_number = ? WHERE id = ?";
            con.query(sql, [first_name, last_name, email, phone_number, decoded.userId], (err, result) => {
                if (err) {
                    console.error("Database error:", err);
                    return res.status(500).json({ error: "Database error" });
                }
                
                if (result.affectedRows === 0) {
                    return res.status(404).json({ error: "User not found" });
                }
                
                console.log("Personal data updated successfully");
                res.json({
                    message: "Personal data updated successfully",
                    first_name: first_name,
                    last_name: last_name,
                    email: email,
                    phone_number: phone_number
                });
            });
        });
    } catch (err) {
        console.error("Token verification error:", err);
        return res.status(401).json({ error: "Invalid token" });
    }
});

module.exports = router;