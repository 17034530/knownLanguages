const express = require("express")
const {createUser} = require("../controller/usersController")
const router = express.Router()

router.route("/createUser").post(createUser)

module.exports = router