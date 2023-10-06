const express = require("express")
const app = express()
const cors = require("cors")

const config = require("dotenv")
config.config({ path: "config/config.env" }) //change to base.env or create a config.env in config

//getting route
const user = require("./route/usersRoute")

app.use(cors())
app.use(express.json())

app.use(user)

app.listen(process.env.PORT, () => {
  console.log(`Host: ${process.env.HOST}`)
  console.log("Port: " + process.env.PORT)
  console.log("running")
})
