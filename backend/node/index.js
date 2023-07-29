const express = require("express")
const app = express()
const mysql = require("mysql")
const cors = require("cors")
const bcrypt = require("bcrypt")

const config = require("dotenv")
config.config({ path: "config/config.env" }) //change to base.env or create a config.env in config

app.use(cors())
app.use(express.json())


app.listen(process.env.PORT, () => {
  console.log(`Host: ${process.env.HOST}`)
  console.log("Port: " + process.env.PORT)
  console.log("running")
})
