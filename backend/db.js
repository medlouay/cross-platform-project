const mysql = require("mysql2")

const con = mysql.createConnection({
    host: "127.0.0.1",
    user: "root",
    password: "admin",
    database: "gym",
    port: 3306
})

con.connect(err => {
    if (err) console.log("DB connection error: " + err)
    else console.log("Connected to MySQL database!")
})

module.exports = con
