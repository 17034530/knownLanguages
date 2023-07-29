const express = require("express")
const {createUser, login } = require("../controller/usersController")
const router = express.Router()

router.route("/createUser").post(createUser)
router.route("/login").post(login)

module.exports = router