const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");
const con = require("../db");
const multer = require("multer");
const path = require("path");
const fs = require("fs");

const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret_key_change_this";

// Configure multer for profile picture upload
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        const uploadDir = 'uploads/profile_pictures';
        // Create directory if it doesn't exist
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, 'profile-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: function (req, file, cb) {
        console.log('Received file:', file);
        console.log('Mimetype:', file.mimetype);
        console.log('Original name:', file.originalname);
        
        // More permissive check
        if (file.mimetype.startsWith('image/')) {
            return cb(null, true);
        } else {
            cb(new Error('Only image files are allowed!'));
        }
    }
});
// GET user profile (including profile_picture)
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
        
        const sql = "SELECT first_name, last_name, email, phone_number, height, weight, age, profile_picture FROM users WHERE id = ?";
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
                age: user.age,
                profile_picture: user.profile_picture
            });
        });
    } catch (err) {
        console.error("Token verification error:", err);
        return res.status(401).json({ error: "Invalid token" });
    }
});

// POST - Upload profile picture
router.post("/upload-picture", upload.single('profile_picture'), (req, res) => {
    console.log("Upload profile picture endpoint hit");
    
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
        
        if (!req.file) {
            return res.status(400).json({ error: "No file uploaded" });
        }

        const profilePicturePath = req.file.filename;
        console.log("Uploading profile picture for userId:", decoded.userId);
        console.log("File path:", profilePicturePath);

        // Delete old profile picture if exists
        const getOldPicSql = "SELECT profile_picture FROM users WHERE id = ?";
        con.query(getOldPicSql, [decoded.userId], (err, results) => {
            if (!err && results.length > 0 && results[0].profile_picture) {
                const oldPicPath = path.join('uploads/profile_pictures', results[0].profile_picture);
                if (fs.existsSync(oldPicPath)) {
                    fs.unlinkSync(oldPicPath);
                    console.log("Deleted old profile picture");
                }
            }
        });

        // Update database with new profile picture
        const sql = "UPDATE users SET profile_picture = ? WHERE id = ?";
        con.query(sql, [profilePicturePath, decoded.userId], (err, result) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Database error" });
            }
            
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: "User not found" });
            }
            
            console.log("Profile picture uploaded successfully");
            res.json({
                message: "Profile picture uploaded successfully",
                profile_picture: profilePicturePath
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

// PATCH - Update personal data (first_name, last_name, email, phone_number)
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