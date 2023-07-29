const express = require("express")
const {createUser, login, profile } = require("../controller/usersController")
const router = express.Router()

router.route("/createUser").post(createUser)
router.route("/login").post(login)
router.route("/profile").post(profile)

module.exports = router